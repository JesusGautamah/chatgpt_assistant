# frozen_string_literal: true

require "active_record"
require "active_model"
require_relative "migrations"
require "fileutils"

module ChatgptAssistant
  # This class is responsible for the configuration of the Chatgpt Assistant
  class Config
    def initialize
      @database_host = ENV["POSTGRES_HOST"]
      @database_name = ENV["POSTGRES_DB"]
      @database_username = ENV["POSTGRES_USER"]
      @database_password = ENV["POSTGRES_PASSWORD"]
      @openai_api_key = ENV["OPENAI_API_KEY"]
      @telegram_token = ENV["TELEGRAM_TOKEN"]
    end

    attr_reader :openai_api_key, :telegram_token

    def db_connection
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        host: database_host,
        port: 5432,
        database: database_name,
        username: database_username,
        password: database_password
      )
      ActiveRecord::Base.logger = Logger.new($stdout)
    end

    def migrate
      db_connection
      ActiveRecord::Base.logger = Logger.new($stdout)
      UserMigration.new.migrate(:up)
      ChatMigration.new.migrate(:up)
      MessageMigration.new.migrate(:up)
    end

    private

    attr_reader :database_host, :database_name, :database_username, :database_password
  end
end
