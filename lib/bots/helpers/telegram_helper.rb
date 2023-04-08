# frozen_string_literal: true

module ChatgptAssistant
  # Helper for telegram
  module TelegramHelper
    def user
      @user = find_user(telegram_id: msg.chat.id)
    end

    def bot
      @bot ||= Telegram::Bot::Client.new(telegram_token)
    end

    def telegram_chat_event
      user ? chat_if_exists : not_logged_in_message
    end

    def telegram_audio_info
      bot.api.get_file(file_id: telegram_audio.file_id)
    end

    def telegram_audio_url
      "https://api.telegram.org/file/bot#{telegram_token}/#{telegram_audio_info["result"]["file_path"]}"
    end

    def telegram_audio
      msg.audio || msg.voice
    end

    def telegram_process_ai_voice(user_audio)
      ai_text = chatter.chat(user_audio["text"], user.current_chat_id)
      ai_voice = synthesis.synthesize_text(ai_text)
      {
        voice: ai_voice,
        text: ai_text
      }
    end

    def telegram_send_voice_message(voice: nil, text: nil)
      messages = parse_message text, 4096
      bot.api.send_voice(chat_id: msg.chat.id, voice: Faraday::UploadIO.new(voice, "audio/mp3"))
      messages.each { |message| send_message message, msg.chat.id }
    end

    def telegram_user_auth(email, password, telegram_id)
      return "wrong password" if password.nil?

      visitor_access = find_visitor(telegram_id: telegram_id)
      return "something went wrong" unless visitor_access

      new_access = find_user(email: email)
      return "user not found" unless new_access

      hash = new_access.password_hash
      salt = new_access.password_salt
      valid_password?(password, hash, salt) ? telegram_user_access(visitor_access, new_access) : "wrong password"
    end

    def telegram_user_access(visitor, new_access)
      other_access = where_user(telegram_id: visitor.telegram_id)
      other_access&.each { |access| access.update(telegram_id: nil) }
      new_access.update(telegram_id: visitor.telegram_id)
      new_access.email
    end

    def telegram_user_create(visitor_id, email, password)
      visitor = Visitor.find_by(id: visitor_id)
      return false unless visitor

      visitor.tel_user.update(telegram_id: nil) if visitor.tel_user.present?
      user = User.new(telegram_id: visitor.telegram_id, email: email, password: password)
      user.save ? user.email : user.errors.full_messages
    end

    def telegram_send_start_message
      send_message commom_messages[:start], msg.chat.id
      help_message = help_messages.join("\n").to_s
      send_message help_message, msg.chat.id
      send_message commom_messages[:start_helper], msg.chat.id
      send_message commom_messages[:start_sec_helper], msg.chat.id
    end

    def telegram_create_chat
      text = msg.text
      title = text.split("/").last
      chat = Chat.new(user_id: user.id, status: 0, title: title)
      chat.save ? chat_created_message(chat) : chat_creation_failed_message
    end

    def telegram_user_history
      user.current_chat.messages.last(10).map { |m| "#{m.role}: #{m.content}\nat: #{m.created_at}" }
    end

    def telegram_text_or_audio?
      msg.respond_to?(:text) || msg.respond_to?(:audio) || msg.respond_to?(:voice)
    end

    def telegram_message_has_text?
      msg.text.present?
    end

    def telegram_message_has_audio?
      msg.audio.present? || msg.voice.present?
    end

    def telegram_actions?
      msg.text.include?("new_chat/") || msg.text.include?("sl_chat/") || msg.text.include?("login/") || msg.text.include?("register/")
    end
  end
end
