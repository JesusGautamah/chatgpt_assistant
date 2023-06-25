# frozen_string_literal: true

module ChatgptAssistant
  module Bots
    module Telegram
      module Actions
        def telegram_user_create(visitor_id, email, password)
          visitor = Visitor.find_by(id: visitor_id)
          return false unless visitor

          visitor.tel_user.update(telegram_id: nil) if visitor.tel_user.present?
          user = User.new(telegram_id: visitor.telegram_id, email: email, password: password)
          user.save ? user.email : user.errors.full_messages
        end

        def telegram_send_start_message
          send_message common_messages[:start], msg.chat.id
          help_message = help_messages.join("\n").to_s
          send_message help_message, msg.chat.id
          send_message common_messages[:start_helper], msg.chat.id
          send_message common_messages[:start_sec_helper], msg.chat.id
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

          chat.save ? chat_created_message(chat) : send_message(chat_id: msg.chat.id, text: error_messages[:chat_creation_failed])
        end

        def chat_created_message(chat)
          bot.api.send_message(chat_id: msg.chat.id, text: "Intructions sended to actor:\n#{chat.prompt}") unless chat.actor.nil?
          bot.api.send_message(chat_id: msg.chat.id, text: "Response from assistant:\n#{chat.messages[1].content}") unless chat.actor.nil?
          bot.api.send_message(chat_id: msg.chat.id, text: success_messages[:chat_created]) if bot.respond_to?(:api)
        end
      end
    end
  end
end
