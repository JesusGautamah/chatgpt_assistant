# frozen_string_literal: true

require_relative "telegram/bot"
require_relative "telegram/auth"
require_relative "telegram/actions"
require_relative "telegram/events"
require_relative "telegram/chat_actions"
require_relative "telegram/validations"
require_relative "telegram/voice_actions"
require_relative "telegram/permissions"
require_relative "telegram/events_controller"

module ChatgptAssistant
  # This class is responsible for the telegram bot features
  class TelegramBot < ApplicationBot
    def start
      bot.listen do |message|
        @msg = message
        @visitor = telegram_visited?(@msg.chat.id)
        next unless telegram_text_or_audio?

        text_events if telegram_message_has_text?
        audio_event if telegram_message_has_audio?
      end
    rescue StandardError => e
      Error.create(message: e.message, backtrace: e.backtrace)
      retry
    end

    private

      attr_accessor :msg, :visitor, :chat, :chat_id

      include Bots::Telegram::Bot
      include Bots::Telegram::Auth
      include Bots::Telegram::Actions
      include Bots::Telegram::Events
      include Bots::Telegram::ChatActions
      include Bots::Telegram::Validations
      include Bots::Telegram::VoiceActions
      include Bots::Telegram::Permissions
      include Bots::Telegram::EventsController
  end
end
