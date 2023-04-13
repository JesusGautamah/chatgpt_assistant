# frozen_string_literal: true

require "active_record"
require "active_model"
require_relative "migrations"
require "fileutils"

module ChatgptAssistant
  # This class is responsible for the configuration of the Chatgpt Assistant
  class Config
    def initialize
      @env_type = ENV.fetch("ENV_TYPE", nil)
      @language = ENV.fetch("LANGUAGE", nil)
      @mode = ENV.fetch("MODE", nil)
      @database_host = ENV.fetch("POSTGRES_HOST", nil)
      @database_name = ENV.fetch("POSTGRES_DB", nil)
      @database_username = ENV.fetch("POSTGRES_USER", nil)
      @database_password = ENV.fetch("POSTGRES_PASSWORD", nil)
      @openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)
      @telegram_token = ENV.fetch("TELEGRAM_TOKEN", nil)
      @discord_token = ENV.fetch("DISCORD_TOKEN", nil)
      @discord_client_id = ENV.fetch("DISCORD_CLIENT_ID", nil)
      @ibm_api_key = ENV.fetch("IBM_API_KEY", nil)
      @ibm_url = ENV.fetch("IBM_URL", nil)
      @aws_access_key_id = ENV.fetch("AWS_ACCESS_KEY_ID", nil)
      @aws_secret_access_key = ENV.fetch("AWS_SECRET_ACCESS_KEY", nil)
      @aws_region = ENV.fetch("AWS_REGION", nil)
      @discord_prefix = ENV.fetch("DISCORD_PREFIX", nil)
    end

    attr_reader :openai_api_key, :telegram_token, :discord_token, :ibm_api_key, :ibm_url,
                :aws_access_key_id, :aws_secret_access_key, :aws_region, :mode, :language,
                :discord_client_id, :discord_public_key, :env_type, :discord_prefix

    def db_connection
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        host: database_host,
        port: 5432,
        database: database_name,
        username: database_username,
        password: database_password
      )
      ActiveRecord::Base.logger = Logger.new($stdout) if ENV["ENV_TYPE"] == "development"
    end

    def migrate
      db_connection
      ActiveRecord::Base.logger = Logger.new($stdout)
      VisitorMigration.new.migrate(:up)
      UserMigration.new.migrate(:up)
      ChatMigration.new.migrate(:up)
      MessageMigration.new.migrate(:up)
      ErrorMigration.new.migrate(:up)
    end

    private

      attr_reader :database_host, :database_name, :database_username, :database_password
  end
end
