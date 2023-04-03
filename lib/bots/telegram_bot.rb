# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for the telegram bot features
  class TelegramBot < ApplicationBot
    def start
      bot.listen do |message|
        @msg = message
        event_callback
      end
    rescue StandardError
      retry
    end

    private

    attr_accessor :msg

    def event_callback
      return unless text_or_audio?

      text_events if msg.text.present?
      audio_event if msg.audio.present? || msg.voice.present?
    end

    def text_events
      case msg.text
      when "/start"
        start_event
      when "/help"
        help_event
      when "/list"
        list_event
      when "/stop"
        stop_event
      when "/hist"
        hist_event
      when nil
        nil_event
      else
        action_events
      end
    end

    def audio_event
      return bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:no_chat_selected]) if user.current_chat.nil?

      chat = user.current_chat
      user_audio = transcribed_file
      message = Message.new(content: user_audio["text"], chat_id: chat.id, role: "user")
      if message.save
        ai_text = chatter.chat(user_audio["text"], chat.id)
        ai_voice = audio_synthesis.synthesize_text(ai_text)
        send_audio_message(ai_voice, ai_text)
        delete_all_voice_files
      else
        bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:message_creation_error])
      end
    end

    def send_audio_message(voice, text)
      bot.api.send_voice(chat_id: msg.chat.id, voice: Faraday::UploadIO.new(voice, "audio/mp3"))
      bot.api.send_message(chat_id: msg.chat.id, text: text)
    end

    def action_events
      return chatter_call unless actions?
      return new_chat if msg.text.include?("new_chat/")
      return select_chat if msg.text.include?("sl_chat/")
      return login if msg.text.include?("login/")
      return register if msg.text.include?("register/")

      invalid_command_error_message
    end

    def login
      user_info = msg.text.split("/").last
      email, password = user_info.split(":")
      case auth_usertelegram(email, password, msg.chat.id)
      when "user not found"
        user_not_found_error_message
      when "wrong password"
        wrong_password_error_message
      when find_useremail(email)
        user_logged_in_message
      end
    end

    def register
      user_info = msg.text.split("/").last
      email, password = user_info.split(":")
      if telegram_user_create(msg.chat.id, email, password, msg.from.username || msg.from.first_name)
        user_created_message
      else
        user_creation_error_message
      end
    end

    def audio
      msg.audio || msg.voice
    end

    def audio_info
      bot.api.get_file(file_id: audio.file_id)
    end

    def audio_url
      "https://api.telegram.org/file/bot#{telegram_token}/#{audio_info["result"]["file_path"]}"
    end

    def transcribed_file
      audio_recognition.transcribe_audio(audio_url)
    end

    def start_event
      bot.api.send_message(chat_id: msg.chat.id, text: commom_messages[:start])
      help_message = help_messages.join("\n").to_s
      bot.api.send_message(chat_id: msg.chat.id, text: help_message)
      bot.api.send_message(chat_id: msg.chat.id, text: commom_messages[:start_helper])
      bot.api.send_message(chat_id: msg.chat.id, text: commom_messages[:start_sec_helper])
    end

    def hist_event
      return not_logged_in_message unless user
      return bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:no_chat_selected]) unless user.current_chat

      if user.current_chat.messages.count.zero?
        return bot.api.send_message(chat_id: msg.chat.id,
                                    text: error_messages[:no_messages_founded])
      end

      response = chat.messages.last(4).map do |mess|
        "#{mess.role}: #{mess.content}\n at: #{mess.created_at}\n\n"
      end.join
      bot.api.send_message(chat_id: msg.chat.id, text: response)
    end

    def select_chat
      return not_logged_in_message unless user

      title = msg.text.split("/").last
      chat = user.chat_by_title(title)
      return chat_not_found_message unless chat

      user.update(current_chat_id: chat.id)
      bot.api.send_message(chat_id: msg.chat.id, text: success_messages[:chat_selected])
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

    def list_event
      return unless valid_for_list_action?

      bot.api.send_message(chat_id: msg.chat.id, text: commom_messages[:chat_list])
      chats_str = ""
      user.chats.each do |chat|
        chats_str += "Chat #{chat.id} - #{chat.title}\n"
      end
      bot.api.send_message(chat_id: msg.chat.id, text: chats_str)
    end

    def valid_for_list_action?
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:not_logged_in]) if user.nil?
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:no_chats_founded]) if user.chats.count.zero?
      !user.nil? && user.chats.count.positive?
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
      bot.api.send_message(chat_id: msg.chat.id, text: chatter.chat(msg.text, chat_id))
    end

    def help_event
      help_messages.each do |message|
        bot.api.send_message(chat_id: msg.chat.id, text: message)
      end
    end

    def stop_event
      bot.api.send_message(chat_id: msg.chat.id, text: commom_messages[:stop])
      bot.api.leave_chat(chat_id: msg.chat.id)
    end

    def nil_event
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:nil])
    end

    def user_logged_message
      user.update(telegram_id: msg.chat.id)
      bot.api.send_message(chat_id: msg.chat.id, text: success_messages[:user_logged_in])
    end

    def invalid_command_error_message
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:invalid_command])
    end

    def wrong_password_error_message
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:password])
    end

    def user_not_found_error_message
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:user_not_found])
    end

    def not_logged_in_message
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:user_not_logged_in])
    end

    def user_created_message
      bot.api.send_message(chat_id: msg.chat.id, text: success_messages[:user_created])
    end

    def user_creation_error_message
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:user_creation])
    end

    def chat_created_message(chat)
      user.update(current_chat_id: chat.id)
      bot.api.send_message(chat_id: msg.chat.id, text: success_messages[:chat_created])
    end

    def chat_creation_failed_message
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:chat_creation_failed])
    end

    def no_chat_selected
      bot.api.send_message(chat_id: msg.chat.id,
                           text: error_messages[:no_chat_selected])
    end

    def chat_not_found_message
      bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:chat_not_found])
    end

    def error_log(err)
      if err.message.to_s.include?("Bad Request: message is too long")
        bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:message_history_too_long])
      else
        bot.api.send_message(chat_id: msg.chat.id, text: error_messages[:something_went_wrong])
      end
    end

    def user
      @user ||= User.find_by(telegram_id: msg.chat.id)
    end

    def bot
      @bot ||= Telegram::Bot::Client.new(telegram_token)
    end

    def text_or_audio?
      msg.respond_to?(:text) || msg.respond_to?(:audio) || msg.respond_to?(:voice)
    end

    def actions?
      msg.text.include?("new_chat/") || msg.text.include?("sl_chat/") || msg.text.include?("login/") || msg.text.include?("register/")
    end
  end
end
