# frozen_string_literal: true

module Bots
  module Discord
    module Bot
      def bot
        @bot ||= Discordrb::Commands::CommandBot.new(
          token: discord_token,
          client_id: discord_client_id,
          prefix: discord_prefix
        )
      end

      def user
        @user = find_user(discord_id: evnt.user.id)
      end

      def bot_init
        at_exit { bot.stop }
        bot.run
      rescue StandardError => e
        Error.create(message: e.message, backtrace: e.backtrace)
        retry
      end
    end
  end
end
