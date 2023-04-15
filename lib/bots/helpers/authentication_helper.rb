# frozen_string_literal: true

module ChatgptAssistant
  # Helper for authentication
  module AuthenticationHelper
    def valid_password?(password, hash, salt)
      BCrypt::Engine.hash_secret(password, salt) == hash
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
      other_access&.each { |access| access.update(telegram_id: nil) } if other_access&.class == Array
      other_access&.update(telegram_id: nil) if other_access&.class == User
      new_access.update(telegram_id: visitor.telegram_id)
      new_access.email
    end

    def discord_user_auth(email, password, discord_id)
      user = find_user(email: email)
      return "user not found" unless user
      return "wrong passwords" if password.nil?

      valid_password?(password, user.password_hash, user.password_salt) ? discord_user_access(discord_id, user.email) : "wrong password"
    end

    def discord_user_access(discord_id, user_email)
      other_access = where_user(discord_id: discord_id)
      other_access&.each { |access| access.update(discord_id: nil) }
      user = find_user(email: user_email)
      user.update(discord_id: discord_id)
      user.email
    end
  end
end
