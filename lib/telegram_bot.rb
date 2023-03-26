# frozen_string_literal: true

require_relative "application_bot"
require "telegram/bot"
require "faraday"

module ChatgptAssistant
  # This class is responsible for the telegram bot features
  class TelegramBot < ApplicationBot
    def start
      start_log
      telegram_bot.listen do |message|
        @msg = message
        next unless text_or_audio?

        main_process
      end
    end

    private

    attr_reader :msg

    def user
      @user ||= User.find_by(telegram_id: msg.chat.id)
    end

    def chatter
      @chatter ||= Chatter.new(openai_api_key)
    end

    def telegram_bot
      @telegram_bot ||= Telegram::Bot::Client.new(telegram_token)
    end

    def audio_recognition
      @audio_recognition ||= AudioRecognition.new(openai_api_key)
    end

    def text_or_audio?
      msg.respond_to?(:text) || msg.respond_to?(:audio) || msg.respond_to?(:voice)
    end

    def chat_actions?
      msg.text.include?("novo_chat/") || msg.text.include?("sl_chat/")
    end

    def valid_for_login_or_register?
      msg.text.match?(/@/) && (msg.text.include?("login/") || msg.text.include?("register/"))
    end

    def main_process
      message_received_log
      message_text_cases if msg.text.present?
      message_audio_process if msg.audio.present? || msg.voice.present?
    rescue StandardError => e
      error_log(e)
    end

    def message_text_cases
      logger.log("MESSAGE TEXT: TRUE")
      case msg.text
      when "/start"
        run_start
      when "/ajuda"
        run_help
      when "/listar"
        list_chats
      when "/stop"
        run_stop
      when "/hist"
        run_hist
      when nil
        run_nil_error
      else
        operations
      end
    end

    def operations
      (valid_for_login_or_register? ? login_or_register : chatter_call) unless chat_actions?
      new_chat if msg.text.include?("novo_chat/")
      select_chat if msg.text.include?("sl_chat/")
    end

    def login_or_register
      msg.text = msg.text.split("/").last
      email, password = msg.text.split(":")
      User.find_by(email: email) ? login(email, password) : register(email, password)
    end

    def login(email, password)
      @user = User.find_by(email: email)
      user.password == password ? user_logged_message : user_not_logged_error_message
    end

    def register(email, password)
      name = msg.from.username || "undefined"
      user = User.new(email: email, password: password, name: name, telegram_id: msg.chat.id)
      user.save ? user_created_message : user_not_created_error_message
    end

    def message_audio_process
      logger.log("MESSAGE AUDIO: TRUE")
      chat = Chat.find(user.current_chat_id)
      audio = msg.audio || msg.voice
      audio_info = telegram_bot.api.get_file(file_id: audio.file_id)
      audio_url = "https://api.telegram.org/file/bot#{telegram_token}/#{audio_info["result"]["file_path"]}"
      transcribe_response = audio_recognition.transcribe_audio(audio_url)
      Message.create(content: transcribe_response, chat_id: chat.id, role: "user")
      text = chatter.chat(transcribe_response, chat.id)
      voice = audio_recognition.synthesize_text(text)
      telegram_bot.api.send_voice(chat_id: msg.chat.id, voice: Faraday::UploadIO.new(voice, "audio/mp3"))
      delete_all_voice_files
    end

    def delete_all_voice_files
      Dir.glob("voice/*").each do |file|
        File.delete(file)
      end
    end

    def run_start
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.welcome_message)
      default_msg.help_messages.each do |message|
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: message)
      end
      default_msg.start_messages.each do |message|
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: message)
      end
    end

    def run_hist
      return not_logged_in_message unless user

      chat = Chat.find(user.current_chat_id)
      if chat
        if chat.messages.count.zero?
          return telegram_bot.api.send_message(chat_id: msg.chat.id,
                                               text: "Nenhuma mensagem foi enviada nesta conversa ainda!")
        end

        response = chat.messages.last(4).map do |mess|
          "#{mess.role}: #{mess.content}\n at: #{mess.created_at}\n\n"
        end.join

        logger.log("HIST RESPONSE: #{response}")

        telegram_bot.api.send_message(chat_id: msg.chat.id, text: response)
      else
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: "Nenhuma conversa foi selecionada ainda!")
      end
    end

    def select_chat
      if user.nil?
        not_logged_in_message
      else
        chat = Chat.find_by(user: user, title: msg.text.split("/").last)
        if chat
          user.update(current_chat_id: chat.id)
          telegram_bot.api.send_message(chat_id: msg.chat.id, text: "Chat selecionado com sucesso!")
        else
          chat_not_found_message
        end
      end
    end

    def new_chat
      user.nil? ? not_logged_in_message : create_chat
    end

    def create_chat
      text = msg.text
      title = text.split("/").last
      chat = Chat.new(user_id: user.id, status: 0, title: title)

      chat.save ? chat_created_message(chat) : chat_creation_failed_message
    end

    def list_chats
      chats = Chat.where(user_id: User.find_by(telegram_id: msg.chat.id).id)
      telegram_bot.api.send_message(chat_id: msg.chat.id,
                                    text: "Aqui está a lista de chats que você está participando:")
      chats_str = ""
      chats.each do |chat|
        chats_str += "Chat #{chat.id} - #{chat.title}\n"
      end
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: chats_str)
    end

    def chatter_call
      user ? chat_if_exists : not_logged_in_message
    end

    def chat_if_exists
      chat = Chat.find_by(user_id: user.id, id: user.current_chat_id)
      chat ? chat_success(chat.id) : chat_failed
    end

    def chat_success(chat_id)
      Message.create(chat_id: chat_id, content: msg.text, role: "user")
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: chatter.chat(msg.text, chat_id))
    end

    def run_help
      default_msg.help_messages.each do |message|
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: message)
      end
    end

    def run_stop
      default_msg.stop_messages.each do |message|
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: message)
      end
      telegram_bot.api.leave_chat(chat_id: msg.chat.id)
    end

    def run_nil_error
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:nil])
    end

    def user_logged_message
      user.update(telegram_id: msg.chat.id)
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: "Usuário logado com sucesso!")
      telegram_bot.api.send_message(chat_id: msg.chat.id,
                                    text: "Agora você pode conversar comigo. Para parar de conversar comigo, digite /stop.")
    end

    def user_not_logged_error_message
      telegram_bot.api.send_message(chat_id: chat_id, text: "Senha incorreta!")
    end

    def not_logged_in_message
      default_msg.not_logged_in_messages.each do |message|
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: message)
      end
    end

    def user_created_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: "Usuário criado com sucesso!")
      telegram_bot.api.send_message(chat_id: msg.chat.id,
                                    text: "Agora você pode conversar comigo. Para parar de conversar comigo, digite /stop.")
    end

    def user_not_created_error_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: "Erro ao criar usuário!")
    end

    def chat_created_message(chat)
      user.update(current_chat_id: chat.id)
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.chat_creation_success_message)
    end

    def chat_creation_failed_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:chat_creation_failed])
    end

    def chat_failed
      telegram_bot.api.send_message(chat_id: msg.chat.id,
                                    text: "Você não está em nenhum chat. Para criar um novo chat, digite /novo_chat.")
    end

    def chat_not_found_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: "Chat não encontrado")
    end

    def start_log
      logger.log("STARTING BOT AT #{Time.now}")
      logger.log("ENVIRONMENT: #{ENV["ENV_TYPE"]}")
    end

    def error_log(e)
      mess = "Algo deu errado, tente novamente mais tarde."
      if e.message.to_s.include?("Bad Request: message is too long")
        mess = "Histórico de mensagens muito grande, talvez seja melhor criar outro chat ou perguntar ao bot sobre alguma recordação específica."
      end
      telegram_bot.api.send_message(chat_id: msg.chat.id,
                                    text: mess)
      if ENV["ENV_TYPE"] == "development" && e.message.to_s.include?("Bad Request: message is too long") == false
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: "ERROR: #{e.message}\n #{e.backtrace}")
      end
      logger.log("ERROR: #{e.message}\n #{e.backtrace}")
    end

    def message_received_log
      logger.log("MESSAGE RECEIVED AT: #{Time.now}")
      logger.log("MESSAGE FROM USER: #{msg.from.first_name} #{msg.from.last_name} - #{msg.from.username}")
    end
  end
end
