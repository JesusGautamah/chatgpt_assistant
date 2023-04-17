# frozen_string_literal: true

require "sidekiq"

module ChatgptAssistant
  # This class is responsible to background the voice connect service
  class VoiceConnectJob
    include Sidekiq::Worker

    def perform(channel_id)
      VoiceConnectService.new(channel_id).call
    end
  end
end
