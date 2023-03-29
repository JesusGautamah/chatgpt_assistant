# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to contain the shared variables between the bot classes
  class ApplicationBot
    def initialize(config)
      @config = config
      @default_msg = DefaultMessages.new(@config.language)
      @logger = ChatterLogger.new
      @openai_api_key = @config.openai_api_key
      @telegram_token = @config.telegram_token
      @discord_token = @config.discord_token
      @database = @config.db_connection
      @mode = @config.mode
    end

    def chatter
      @chatter ||= Chatter.new(openai_api_key)
    end

    def audio_recognition
      @audio_recognition ||= AudioRecognition.new(openai_api_key)
    end

    def audio_synthesis
      @audio_synthesis ||= AudioSynthesis.new(config)
    end

    def message_create(message, chat_id, role)
      Message.create(content: message, chat_id: chat_id, role: role)
    end

    attr_reader :openai_api_key, :telegram_token, :database, :default_msg, :logger, :mode, :config
  end
end
