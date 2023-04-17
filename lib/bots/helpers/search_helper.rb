# frozen_string_literal: true

module ChatgptAssistant
  # Helper for search
  module SearchHelper
    def find_visitor(telegram_id: nil, discord_id: nil)
      if telegram_id
        Visitor.find_by(telegram_id: telegram_id)
      elsif discord_id
        Visitor.find_by(discord_id: discord_id)
      end
    end

    def find_user(telegram_id: nil, discord_id: nil, email: nil)
      if telegram_id
        User.find_by(telegram_id: telegram_id)
      elsif discord_id
        User.find_by(discord_id: discord_id)
      elsif email
        User.find_by(email: email)
      end
    end

    def where_user(telegram_id: nil, discord_id: nil, email: nil)
      if telegram_id
        User.where(telegram_id: telegram_id).to_a
      elsif discord_id
        User.where(discord_id: discord_id).to_a
      elsif email
        User.where(email: email).to_a
      end
    end
  end
end
