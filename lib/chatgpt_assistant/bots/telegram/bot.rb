# frozen_string_literal: true

module ChatgptAssistant
  module Bots
    module Telegram
      module Bot
        def bot
          @bot ||= ::Telegram::Bot::Client.new(telegram_token, logger: Logger.new($stderr))
        end

        def user
          @user = find_user(telegram_id: msg.chat.id)
        end
      end
    end
  end
end
