# frozen_string_literal: true

module ChatgptAssistant
  # This module is responsible for the validation of the bot actions
  module ValidationHelper
    def valid_for_list_action?
      not_logged_in_message if user.nil?
      chat_not_found_message if user.chats.count.zero?
      !user.nil? && user.chats.count.positive?
    end

    def chat_if_exists
      chat = Chat.find_by(user_id: user.id, id: user.current_chat_id)
      chat ? chat_success(chat.id) : no_chat_selected_message
    end

    def visitor_user?
      visitor&.tel_user.nil? && visitor&.dis_user.nil?
    end
  end
end
