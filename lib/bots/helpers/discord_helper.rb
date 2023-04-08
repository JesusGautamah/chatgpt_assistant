# frozen_string_literal: true

module ChatgptAssistant
  # Helper for discord
  module DiscordHelper
    def auth_userdiscord(email, password, discord_id)
      user = find_user(email: email)
      return "user not found" unless user
      return "wrong passwords" if password.nil?

      valid_password?(password, user.password_hash, user.password_salt) ? user_disc_access(discord_id, user.email) : "wrong password"
    end

    def user_disc_access(discord_id, user_email)
      last_access = find_user(discord_id: discord_id)
      new_access = find_user(email: user_email)
      last_acess.update(discord_id: nil) if last_access&.email != new_access&.email
      new_access&.update(discord_id: discord_id)
      new_access.email
    end

    def discord_user_create(discord_id, email, password)
      user = User.new(discord_id: discord_id, email: email, password: password)
      last_access = find_user(discord_id: discord_id)
      last_access&.update(discord_id: nil)
      user.save
    end
  end
end
