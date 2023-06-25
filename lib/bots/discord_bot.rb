# frozen_string_literal: true

require_relative "discord/bot"
require_relative "discord/auth"
require_relative "discord/actions"
require_relative "discord/chat_actions"
require_relative "discord/events"
require_relative "discord/voice_actions"
require_relative "discord/voice_checkers"

module ChatgptAssistant
  # This class is responsible to handle the discord bot
  class DiscordBot < ApplicationBot
    def start
      start_event
      login_event
      list_event
      hist_event
      help_event
      new_chat_event
      sl_chat_event
      ask_event
      voice_connect_event
      voice_disconnect_event
      private_message_event
      bot_init
    end

    private

      include Bots::Discord::Bot
      include Bots::Discord::Auth
      include Bots::Discord::Actions
      include Bots::Discord::ChatActions
      include Bots::Discord::Events
      include Bots::Discord::VoiceActions
      include Bots::Discord::VoiceCheckers

      attr_reader :message
      attr_accessor :evnt, :user, :chats, :chat
  end
end
