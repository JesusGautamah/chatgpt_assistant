# frozen_string_literal: true

require_relative "../chatgpt_assistant"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://redis:6379/1") }
end
