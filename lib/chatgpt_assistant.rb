# frozen_string_literal: true

require_relative "chatgpt_assistant/version"
require_relative "chatgpt_assistant/config"
require_relative "chatgpt_assistant/models"
require_relative "chatgpt_assistant/chatter"
require_relative "chatgpt_assistant/chatter_logger"
require_relative "chatgpt_assistant/default_messages"
require_relative "chatgpt_assistant/audio_recognition"
require_relative "telegram_bot"

module ChatgptAssistant
  # This class is responsible for initializing the Chatgpt Assistant
  class Main
    def initialize(mode)
      @mode = mode
    end

    def start
      return telegram_bot if telegram_mode?
      return discord_bot if discord_mode?

      raise "Invalid mode"
    end

    private

    attr_reader :mode

    def telegram_mode?
      mode == "telegram"
    end

    def telegram_bot
      TelegramBot.new.start
    end

    def discord_mode; end
  end
end
