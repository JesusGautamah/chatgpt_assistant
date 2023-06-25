# frozen_string_literal: true

module Bots
  module Discord
    module ChatActions
      def ask_action
        @chat = Chat.where(id: user.current_chat_id).last
        send_message error_messages[:chat_not_found] if chat.nil?
        @message = Message.new(chat_id: chat.id, content: message, role: "user") if chat
        (message.save ? answer_action : send_message(error_messages[:message_not_saved])) if chat
      end

      def private_message_action
        @chat = Chat.where(id: user.current_chat_id).last
        send_message error_messages[:chat_not_found] if chat.nil?
        @message = Message.new(chat_id: chat.id, content: message, role: "user") if chat
        (message.save ? answer_action : send_message(error_messages[:message_not_saved])) if chat
      end

      def answer_action
        response = chatter.chat(message.content, chat.id, error_messages[:something_went_wrong])
        send_message response
      end
    end
  end
end
