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
      mode = nil
      if title.include?(":")
        mode = title.split(":").last
        title = title.split(":").first
      end
      actor_modes = AwesomeChatgptActors::CastControl.actors
      return send_message "invalid mode", msg.chat.id unless (mode.to_i >= 1 && mode.to_i <= actor_modes.size + 1) || mode.nil?
      return send_message "invalid chat title", msg.chat.id if title.nil? || title.empty?
      return send_message "You already have a chat with this title", msg.chat.id if user.chat_by_title(title)

      actor_name = actor_modes[mode.to_i - 1] if mode
      actor = AwesomeChatgptActors::Actor.new(prompt_type: actor_name) if actor_name
      chat = Chat.new(user_id: user.id, status: 0, title: title, actor: actor_name, prompt: actor.prompt) if actor
      chat = Chat.new(user_id: user.id, status: 0, title: title) unless actor
      return send_message "Something went wrong", msg.chat.id unless chat

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
