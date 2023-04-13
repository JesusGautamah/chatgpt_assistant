# frozen_string_literal: true

require_relative "chatgpt_assistant/audio_recognition"
require_relative "chatgpt_assistant/default_messages"
require_relative "chatgpt_assistant/audio_synthesis"
require_relative "chatgpt_assistant/chatter"
require_relative "chatgpt_assistant/version"
require_relative "chatgpt_assistant/config"
require_relative "chatgpt_assistant/models"
require_relative "bots/application_bot"
require_relative "bots/telegram_bot"
require_relative "bots/discord_bot"
require "awesome_chatgpt_actors"
require "streamio-ffmpeg"
require "aws-sdk-polly"
require "telegram/bot"
require "ibm_watson"
require "discordrb"
require "faraday"
require "bcrypt"

module ChatgptAssistant
  # This class is responsible for initializing the Chatgpt Assistant
  class Main
    def initialize(mode)
      @mode = mode
      @config = Config.new
    end

    def start
      return telegram_bot if telegram_mode?
      return discord_bot if discord_mode?

      raise "Invalid mode"
    rescue StandardError => e
      save_error(e)
      retry
    end

    private

      attr_reader :mode, :config

      def save_error(err)
        puts "Error: #{err.message}"
        err.backtrace.each { |line| puts line }
        Error.create(message: err.message, backtrace: err.backtrace) unless err.message == Error.last&.message
      rescue StandardError
        puts "Error: #{err.message}"
        puts "Backtrace: #{err.backtrace}"
      end

      def telegram_mode?
        mode == "telegram"
      end

      def telegram_bot
        TelegramBot.new(config).start
      end

      def discord_mode?
        mode == "discord"
      end

      def discord_bot
        DiscordBot.new(config).start
      end
  end
end
