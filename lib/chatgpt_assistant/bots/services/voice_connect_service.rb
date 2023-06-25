# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to handle the discord bot
  class VoiceConnectService
    def initialize(channel_id)
      @channel_id = channel_id
      @config = Config.new
      # @config.db_connection
    end

    def bot
      @bot ||= Discordrb::Bot.new(token: @config.discord_token)
    end

    def call
      bot.run :async
      channel = bot.channel(@channel_id)

      bot.voice_connect(channel)
      bot.join
      true
    rescue StandardError => e
      puts e.message
      e.backtrace.each { |line| puts line }
      false
    end
  end
end
