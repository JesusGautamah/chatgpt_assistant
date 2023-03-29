# frozen_string_literal: true

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

    attr_accessor :msg

    def user
      @user ||= User.find_by(telegram_id: msg.chat.id)
    end

    def telegram_bot
      @telegram_bot ||= Telegram::Bot::Client.new(telegram_token)
    end

    def text_or_audio?
      msg.respond_to?(:text) || msg.respond_to?(:audio) || msg.respond_to?(:voice)
    end

    def chat_actions?
      msg.text.include?("new_chat/") || msg.text.include?("sl_chat/")
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
      when "/help"
        run_help
      when "/list"
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
      new_chat if msg.text.include?("new_chat/")
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

    def audio
      msg.audio || msg.voice
    end

    def audio_info
      telegram_bot.api.get_file(file_id: audio.file_id)
    end

    def audio_url
      "https://api.telegram.org/file/bot#{telegram_token}/#{audio_info["result"]["file_path"]}"
    end

    def transcribed_text
      audio_recognition.transcribe_audio(audio_url)
    end
    
    def message_audio_process
      logger.log("MESSAGE AUDIO: TRUE")
      chat = Chat.find(user.current_chat_id)
      message_create(transcribed_text, chat.id, "user")
      text = chatter.chat(transcribed_text, chat.id)
      voice = audio_synthesis.synthesize_text(text)
      telegram_bot.api.send_voice(chat_id: msg.chat.id, voice: Faraday::UploadIO.new(voice, "audio/mp3"))
      delete_all_voice_files
    end

    def delete_all_voice_files
      Dir.glob("voice/*").each do |file|
        File.delete(file)
      end
    end

    def run_start
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.commom_messages[:start])
      default_msg.help_messages.each do |message|
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: message)
      end
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.commom_messages[:start_helper])
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.commom_messages[:start_sec_helper])
    end

    def run_hist
      return not_logged_in_message unless user

      chat = Chat.find(user.current_chat_id)
      if chat
        return telegram_bot.api.send_message(chat_id: msg.chat.id,
                                             text: default_msg.error_messages[:no_messages_founded]) if chat.messages.count.zero?

        response = chat.messages.last(4).map do |mess|
          "#{mess.role}: #{mess.content}\n at: #{mess.created_at}\n\n"
        end.join

        logger.log("HIST RESPONSE: #{response}")

        telegram_bot.api.send_message(chat_id: msg.chat.id, text: response)
      else
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:no_chat_selected])
      end
    end

    def select_chat
      if user.nil?
        not_logged_in_message
      else
        chat = Chat.find_by(user: user, title: msg.text.split("/").last)
        if chat
          user.update(current_chat_id: chat.id)
          telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.success_messages[:chat_selected])
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
      chat ? chat_success(chat.id) : no_chat_selected
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
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.commom_messages[:stop])
      telegram_bot.api.leave_chat(chat_id: msg.chat.id)
    end

    def run_nil_error
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:nil])
    end

    def user_logged_message
      user.update(telegram_id: msg.chat.id)
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.success_messages[:user_logged_in])
    end

    def user_not_logged_error_message
      telegram_bot.api.send_message(chat_id: chat_id, text: default_msg.error_messages[:password])
    end

    def not_logged_in_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:user_not_logged_in])
    end

    def user_created_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.success_messages[:user_created])
    end

    def user_not_created_error_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:user_creation])
    end

    def chat_created_message(chat)
      user.update(current_chat_id: chat.id)
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.success_messages[:chat_created])
    end

    def chat_creation_failed_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:chat_creation_failed])
    end

    def no_chat_selected
      telegram_bot.api.send_message(chat_id: msg.chat.id,
                                    text: default_msg.error_messages[:no_chat_selected])
    end

    def chat_not_found_message
      telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:chat_not_found])
    end

    def start_log
      logger.log("STARTING BOT AT #{Time.now}")
      logger.log("ENVIRONMENT: #{@config.env_type}")
    end


    def error_log(e)
      if e.message.to_s.include?("Bad Request: message is too long")
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:message_history_too_long])
      else
        telegram_bot.api.send_message(chat_id: msg.chat.id, text: default_msg.error_messages[:something_went_wrong])
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
