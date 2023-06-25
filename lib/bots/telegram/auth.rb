# frozen_string_literal: true

module Bots
  module Telegram
    module Auth
      def authenticate_user(email, password)
        case telegram_user_auth(email, password, msg.chat.id)
        when "user not found"
          raise UserNotFoundError
        when "wrong password"
          raise WrongPasswordError
        when email
          send_message(chat_id: msg.chat.id, text: success_messages[:user_logged_in])
        end
      end

      def telegram_user_auth(email, password, telegram_id)
        return "wrong password" if password.nil?

        visitor_access = find_visitor(telegram_id: telegram_id)
        return "something went wrong" unless visitor_access

        new_access = find_user(email: email)
        return "user not found" unless new_access

        user.valid_password?(password) ? telegram_user_access(visitor_access, new_access) : "wrong password"
      end

      def telegram_user_access(visitor, new_access)
        other_access = where_user(telegram_id: visitor.telegram_id)
        other_access&.each { |access| access.update(telegram_id: nil) } if other_access&.class == Array
        other_access&.update(telegram_id: nil) if other_access&.class == User
        new_access.update(telegram_id: visitor.telegram_id)
        new_access.email
      end
    end
  end
end
