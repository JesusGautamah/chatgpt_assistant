# frozen_string_literal: true

module Bots
  module Discord
    module Auth
      def discord_visited?(user_id)
        return unless evnt

        visitor = Visitor.find_by(discord_id: user_id, name: evnt.user.name)
        if visitor.nil?
          Visitor.create(discord_id: user_id, name: evnt.user.name)
        else
          visitor
        end
      end

      def discord_user_auth(email, password, discord_id)
        user = find_user(email: email)
        return "user not found" unless user
        return "wrong passwords" if password.nil?

        user.valid_password?(password) ? discord_user_access(discord_id, user.email) : "wrong password"
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
end
