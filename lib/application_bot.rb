# frozen_string_literal: true
require_relative "chatgpt_assistant/models"

module ChatgptAssistant
  # This class is responsible to contain the shared variables between the bot classes
  class ApplicationBot
    def initialize
      @config = Config.new
      @openai_api_key = @config.openai_api_key
      @telegram_token = @config.telegram_token
      @database = @config.db_connection
      @default_msg = DefaultMessages
      @logger = ChatterLogger.new
      @mode = ENV["MODE"]
    end

    def chatter
      @chatter ||= Chatter.new(openai_api_key)
    end

    def audio_recognition
      @audio_recognition ||= AudioRecognition.new(openai_api_key)
    end

    def audio_synthesis
      @audio_synthesis ||= AudioSynthesis.new(openai_api_key, mode)
    end

    def message_create(message, chat_id, role)
      Message.create(content: message, chat_id: chat_id, role: role)
    end

    attr_reader :openai_api_key, :telegram_token, :database, :default_msg, :logger, :mode
  end
end
