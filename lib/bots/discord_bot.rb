# frozen_string_literal: true

require_relative "helpers/discord_helper"
require_relative "helpers/discord_voice_helper"

module ChatgptAssistant
  # This class is responsible to handle the discord bot
  class DiscordBot < ApplicationBot
    def start
      start_event
      login_event
      register_event
      list_event
      hist_event
      help_event
      new_chat_event
      sl_chat_event
      ask_event
      private_message_event
      bot_init
    end

    private

      include DiscordHelper
      include DiscordVoiceHelper

      attr_reader :message
      attr_accessor :evnt, :user, :chats, :chat

      def start_event
        bot.command :start do |event|
          @evnt = event
          @user = event.user
          start_action
          "Ok"
        end
      end

      def login_event
        bot.command :login do |event|
          @message = event.message.content.split[1]
          @evnt = event
          message.nil? ? event.respond(common_messages[:login]) : login_action
          "OK"
        end
      end

      def register_event
        bot.command :register do |event|
          @message = event.message.content.split[1]
          @evnt = event
          message.nil? ? event.respond(common_messages[:register]) : register_action
          "OK"
        end
      end

      def list_event
        bot.command :list do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          valid_for_list_action? ? list_action : ""
          "OK"
        end
      end

      def hist_event
        bot.command :hist do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          @chat = user.current_chat
          event.respond error_messages[:chat_not_found] if chat.nil? && user
          hist_action if user && chat
          "OK"
        end
      end

      def help_event
        bot.command :help do |event|
          @evnt = event
          help_action
          "OK"
        end
      end

      def new_chat_event
        bot.command :new_chat do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          event.respond error_messages[:user_not_logged_in] if user.nil?
          create_chat_action if user
          "OK"
        end
      end

      def sl_chat_event
        bot.command :sl_chat do |event|
          @evnt = event
          chat_to_select = event.message.content.split[1..].join(" ")
          @user = find_user(discord_id: event.user.id)
          event.respond error_messages[:user_not_logged_in] if user.nil?

          sl_chat_action(chat_to_select) if user
          "OK"
        end
      end

      def ask_event
        bot.command :ask do |event|
          @evnt = event
          @message = event.message.content.split[1..].join(" ")
          @user = find_user(discord_id: event.user.id)
          event.respond error_messages[:user_not_logged_in] if user.nil?
          ask_action if user
          "OK"
        end
      end

      def voice_connect_event
        bot.command :connect do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          if user&.current_chat_id.nil?
            event.respond error_messages[:no_chat_selected]
          elsif user&.current_chat_id
            @chat = Chat.where(id: user.current_chat_id).last
            voice_connect_checker_action
            voice_connection_checker_action
            VoiceConnectJob.perform_async(event.user.voice_channel.id)
          else
            event.respond error_messages[:user_not_logged_in]
          end
          "OK"
        end
      end

      def disconnect_event
        bot.command :disconnect do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          disconnect_checker_action
          disconnect_action if user && event.user.voice_channel && event.voice
          "OK"
        end
      end

      def speak_event
        bot.command :speak do |event|
          @evnt = event
          @message = event.message.content.split[1..].join(" ")
          @user = find_user(discord_id: event.user.id)
          @chat = user.current_chat
          speak_connect_checker_action
          speak_connection_checker_action
          ask_to_speak_action if user && event.user.voice_channel && event.voice && !chat.nil?
          "OK"
        end
      end

      def private_message_event
        bot.message do |event|
          @evnt = event
          @visitor = discord_visited?(@evnt.user.id)
          next if discord_next_action?

          @message = event.message.content
          @user = find_user(discord_id: event.user.id)
          @chat = user.current_chat if user
          private_message_action if user && !chat.nil?
          "OK"
        end
      end

      def bot_init
        at_exit { bot.stop }
        bot.run
      rescue StandardError => e
        Error.create(message: e.message, backtrace: e.backtrace)
        retry
      end
  end
end
