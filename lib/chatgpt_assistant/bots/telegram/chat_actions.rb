# frozen_string_literal: true

module ChatgptAssistant
  module Bots
    module Telegram
      module ChatActions
        def chat_if_exists
          chat = Chat.find_by(user_id: user.id, id: user.current_chat_id)
          chat ? chat_success(chat.id) : send_message(chat_id: msg.chat.id, text: error_messages[:no_chat_selected])
        end

        def chat_success(chat_id)
          user_message = Message.new(chat_id: chat_id, content: msg.text, role: "user")
          if user_message&.save
            text = chatter.chat(msg.text, chat_id, error_messages[:something_went_wrong])
            mess = parse_message(text, 4096)
            mess.each { |m| send_message m, msg.chat.id }
          else
            send_message error_messages[:something_went_wrong], msg.chat.id
          end
        end

        def send_message(text, chat_id)
          messages = parse_message(text, 4096)
          messages.each { |m| bot.api.send_message(chat_id: chat_id, text: m) }
        end
      end
    end
  end
end
