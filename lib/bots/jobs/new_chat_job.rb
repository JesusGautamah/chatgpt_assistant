# frozen_string_literal: true

require "sidekiq"

module ChatgptAssistant
  # This class is responsible to background the new chat service
  class NewChatJob
    include Sidekiq::Job

    def perform(chat_title, user_id, chat_id)
      @config = Config.new
      @config.db_connection

      NewChatService.new(chat_title, user_id, chat_id, @config).call
    end
  end
end
