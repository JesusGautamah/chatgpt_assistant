# frozen_string_literal: true

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
    end

    attr_reader :openai_api_key, :telegram_token, :database, :default_msg, :logger
  end
end
