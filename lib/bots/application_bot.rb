# frozen_string_literal: true

require_relative "helpers/messenger_helper"
require_relative "helpers/authentication_helper"
require_relative "helpers/visit_helper"
require_relative "helpers/audio_helper"
require_relative "helpers/logger_action_helper"
require_relative "helpers/discord_helper"
require_relative "helpers/search_helper"
require_relative "helpers/validation_helper"

module ChatgptAssistant
  # This class is responsible to contain the shared variables between the bot classes
  class ApplicationBot
    include MessengerHelper
    include AuthenticationHelper
    include VisitHelper
    include AudioHelper
    include LoggerActionHelper
    include DiscordHelper
    include SearchHelper
    include ValidationHelper

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
      @commom_messages = default_msg.commom_messages
      @error_messages = default_msg.error_messages
      @success_messages = default_msg.success_messages
      @help_messages = default_msg.help_messages
    end

    attr_reader :openai_api_key, :telegram_token, :database, :default_msg,
                :mode, :config, :discord_token, :discord_client_id,
                :discord_prefix, :commom_messages, :error_messages, :success_messages,
                :help_messages
    attr_accessor :msg, :evnt, :bot, :audio_url, :visitor, :user, :chat, :chat_id

    def chatter
      @chatter ||= Chatter.new(openai_api_key)
    end
  end
end
