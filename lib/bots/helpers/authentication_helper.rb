# frozen_string_literal: true

module ChatgptAssistant
  # Helper for authentication
  module AuthenticationHelper
    def telegram_user_auth(email, password, telegram_id)
      return "wrong password" if password.nil?

      visitor_access = find_visitor(telegram_id: telegram_id)
      return "something went wrong" unless visitor_access

      new_access = find_user(email: email)
      return "user not found" unless new_access

      hash = new_access.password_hash
      salt = new_access.password_salt
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
