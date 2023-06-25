# frozen_string_literal: true

module ChatgptAssistant
  module Bots
    module Telegram
      module Permissions
        def hist_allowed?
          raise UserNotLoggedInError if user.nil?
          raise AccountNotVerifiedError unless user.active?
          raise NoChatSelectedError if user.current_chat.nil?
          raise NoMessagesFoundedError if user.current_chat.messages.count.zero?
        end

        def list_allowed?
          raise UserNotLoggedInError if user.nil?
          raise AccountNotVerifiedError unless user.active?
          raise NoChatsFoundedError if user.chats.count.zero?
        end

        def register_allowed?(user_info)
          raise NoRegisterInfoError if user_info.nil?
          raise UserLoggedInError if user

          email, password = user_info.split(":")
          raise NoRegisterEmailError if email.nil? || password.nil?

          [email, password]
        end

        def common_allowed?
          raise UserNotLoggedInError if user.nil?
          raise AccountNotVerifiedError unless user.active?
        end

        def select_allowed?(chat)
          raise ChatNotFoundError if chat.nil?
          raise ChatNotFoundError unless user.update(current_chat_id: chat.id)
        end

        def audio_allowed?
          raise UserNotLoggedInError if user.nil?
          raise AccountNotVerifiedError unless user.active?
          raise NoChatSelectedError if user.current_chat.nil?
        end
      end
    end
  end
end
