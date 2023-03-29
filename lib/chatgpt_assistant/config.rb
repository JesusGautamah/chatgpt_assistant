# frozen_string_literal: true

require "active_record"
require "active_model"
require_relative "migrations"
require "fileutils"

module ChatgptAssistant
  # This class is responsible for the configuration of the Chatgpt Assistant
  class Config
    def initialize
      @env_type = ENV["ENV_TYPE"]
      @language = ENV["LANGUAGE"]
      @mode = ENV["MODE"]
      @database_host = ENV["POSTGRES_HOST"]
      @database_name = ENV["POSTGRES_DB"]
      @database_username = ENV["POSTGRES_USER"]
      @database_password = ENV["POSTGRES_PASSWORD"]
      @openai_api_key = ENV["OPENAI_API_KEY"]
      @telegram_token = ENV["TELEGRAM_TOKEN"]
      @discord_token = ENV["DISCORD_TOKEN"]
      @ibm_api_key = ENV["IBM_API_KEY"]
      @ibm_url = ENV["IBM_URL"]
      @aws_access_key_id = ENV["AWS_ACCESS_KEY_ID"]
      @aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
      @aws_region = ENV["AWS_REGION"]
    end

    attr_reader :openai_api_key, :telegram_token, :discord_token, :ibm_api_key, :ibm_url,
                :aws_access_key_id, :aws_secret_access_key, :aws_region, :mode, :language,
                :env_type

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
