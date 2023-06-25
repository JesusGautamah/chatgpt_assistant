# frozen_string_literal: true

# helpers
require_relative "helpers/messenger_helper"
require_relative "helpers/audio_helper"
require_relative "helpers/search_helper"
require_relative "helpers/file_helper"

# jobs
require_relative "jobs/register_job"
require_relative "jobs/new_chat_job"
require_relative "jobs/voice_connect_job"

# services
require_relative "services/register_service"
require_relative "services/new_chat_service"
require_relative "services/voice_connect_service"

module ChatgptAssistant
  # This class is responsible to contain the shared attributes and methods
  class ApplicationBot
    include MessengerHelper
    include AudioHelper
    include SearchHelper
    include FileHelper

    def initialize(config)
      @config = config
      default_msg = DefaultMessages.new(@config.language)
      @openai_api_key = @config.openai_api_key
      @telegram_token = @config.telegram_token
      @discord_token = @config.discord_token
      @discord_client_id = @config.discord_client_id
      @discord_prefix = @config.discord_prefix
      @database = @config.db_connection
      @mode = @config.mode
      @common_messages = default_msg.common_messages
      @error_messages = default_msg.error_messages
      @success_messages = default_msg.success_messages
      @help_messages = default_msg.help_messages
    end

    attr_reader :openai_api_key, :telegram_token, :database, :default_msg,
                :mode, :config, :discord_token, :discord_client_id,
                :discord_prefix, :common_messages, :error_messages, :success_messages,
                :help_messages
    attr_accessor :msg, :evnt, :bot, :audio_url, :visitor, :user, :chat, :chat_id

    def chatter
      @chatter ||= Chatter.new(openai_api_key)
    end
  end
end
