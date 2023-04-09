# frozen_string_literal: true

require_relative "helpers/discord_helper"

module ChatgptAssistant
  # This class is responsible to handle the discord bot
  class DiscordBot < ApplicationBot
    include DiscordHelper

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
      voice_connect_event
      disconnect_event
      speak_event
      bot_init
    end

    private

      attr_reader :message
      attr_accessor :evnt, :user, :chats, :chat

      def start_event
        bot.command :start do |event|
          @evnt = event
          @user = event.user
          start_action
        end
      end

      def login_event
        bot.command :login do |event|
          @message = event.message.content.split(" ")[1]
          @evnt = event
          message.nil? ? event.respond(commom_messages[:login]) : login_action
        end
      end

      def login_action
        user_email = message.split(":")[0]
        user_password = message.split(":")[1]
        case auth_userdiscord(user_email, user_password, evnt.user.id)
        when "user not found"
          evnt.respond error_messages[:user_not_found]
        when "wrong password"
          puts "wrong password"
          evnt.respond error_messages[:wrong_password]
        when find_user(email: user_email).email
          evnt.respond success_messages[:user_logged_in]
        end
      end

      def register_event
        bot.command :register do |event|
          @message = event.message.content.split(" ")[1]
          @evnt = event
          message.nil? ? event.respond(commom_messages[:register]) : register_action
        end
      end

      def register_action
        user_email = message.split(":")[0]
        user_password = message.split(":")[1]
        if find_user(email: user_email).nil?
          create_user_action(user_email,
                             user_password)
        else
          evnt.respond(error_messages[:user_already_exists])
        end
      end

      def create_user_action(mail, pass)
        id = evnt.user.id
        if discord_user_create(id, mail, pass)
          evnt.respond(success_messages[:user_created])
        else
          evnt.respond(error_messages[:user_not_created])
        end
      end

      def list_event
        bot.command :list do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          event.respond error_messages[:user_not_logged_in] if user.nil?
          event.respond error_messages[:chat_not_found] if user.chats.empty? && user
          list_action if user && !user.chats.empty?
        end
      end

      def list_action
        chats_title = user.chats.map(&:title)
        evnt.respond commom_messages[:chat_list]
        evnt.respond chats_title.join("\n")
      end

      def hist_event
        bot.command :hist do |event|
          @evnt = event
          event.respond error_messages[:user_not_logged_in] if user.nil?
          title = event.message.content.split(" ")[1..].join(" ")
          @chat = user.chat_by_title(title)
          event.respond error_messages[:chat_not_found] if chat.nil? && user
          hist_action if user && chat
        end
      end

      def hist_action
        messages = Message.where(chat_id: chat.id).order(:created_at)
        messages.each do |message|
          evnt.respond "#{message.role} - #{message.content}\n#{message.created_at.strftime("%d/%m/%Y %H:%M")}"
        end
        "This is the end of the chat history"
      end

      def help_event
        bot.command :help do |event|
          @evnt = event
          help_action
        end
      end

      def help_action
        message = help_messages.join("\n").gsub(" /", discord_prefix)
                               .gsub("register/", "#{discord_prefix}register ")
                               .gsub("login/", "#{discord_prefix}login ")
                               .gsub("new_chat/", "#{discord_prefix}new_chat/")
                               .gsub("sl_chat/", "#{discord_prefix}sl_chat/")
        evnt.respond message
      end

      def new_chat_event
        bot.command :new_chat do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          event.respond error_messages[:user_not_logged_in] if user.nil?
          create_chat_action if user
        end
      end

      def create_chat_action
        chat_title = evnt.message.content.split(" ")[1..].join(" ")
        @chat = Chat.new(user_id: user.id, title: chat_title, status: 0)
        chat.save ? respond_with_success : evnt.respond(error_messages[:chat_creation])
      end

      def respond_with_success
        user.update(current_chat_id: chat.id)
        evnt.respond success_messages[:chat_created]
      end

      def sl_chat_event
        bot.command :sl_chat do |event|
          @evnt = event
          chat_to_select = event.message.content.split(" ")[1..].join(" ")
          @user = find_user(discord_id: event.user.id)
          event.respond error_messages[:user_not_logged_in] if user.nil?

          sl_chat_action(chat_to_select) if user
        end
      end

      def sl_chat_action(chat_to_select)
        @chat = user.chat_by_title(chat_to_select)
        evnt.respond error_messages[:chat_not_found] if chat.nil?
        user.update(current_chat_id: chat.id) if chat
        evnt.respond success_messages[:chat_selected] if chat
      end

      def ask_event
        bot.command :ask do |event|
          @evnt = event
          @message = event.message.content.split(" ")[1..].join(" ")
          @user = find_user(discord_id: event.user.id)
          event.respond error_messages[:user_not_logged_in] if user.nil?
          ask_action if user
        end
      end

      def ask_action
        @chat = Chat.where(id: user.current_chat_id).last
        evnt.respond error_messages[:chat_not_found] if chat.nil?
        @message = Message.new(chat_id: chat.id, content: message, role: "user") if chat
        (message.save ? answer_action : evnt.respond(error_messages[:message_not_saved])) if chat
      end

      def answer_action
        response = chatter.chat(message.content, chat.id)
        evnt.respond response
      end

      def voice_connect_event
        bot.command :connect do |event|
          @evnt = event
          @user = find_user(discord_id: event.user.id)
          @chat = Chat.where(id: user.current_chat_id).last
          voice_connect_checker_action
          voice_connection_checker_action
          bot.voice_connect(event.user.voice_channel) if bot_disconnected?
          bot_connected? ? "Connected to voice channel" : "Error connecting to voice channel"
        end
      end

      def voice_connect_checker_action
        evnt.respond error_messages[:user_not_logged_in] if user.nil?
        evnt.respond error_messages[:chat_not_found] if user && chat.nil?
      end

      def voice_connection_checker_action
        evnt.respond error_messages[:user_not_in_voice_channel] if evnt.user.voice_channel.nil? && user
        evnt.respond error_messages[:bot_already_connected] if evnt.voice && user
      end

      def bot_disconnected?
        user && evnt.user.voice_channel && !evnt.voice && !chat.nil?
      end

      def bot_connected?
        user && evnt.user.voice_channel && evnt.voice && !chat.nil?
      end

      def disconnect_event
        bot.command :disconnect do |event|
          @evnt = event
          @user = find_userdiscord(event.user.id)
          disconnect_checker_action
          disconnect_action if user && event.user.voice_channel && event.voice
        end
      end

      def disconnect_checker_action
        evnt.respond error_messages[:user_not_logged_in] if user.nil?
        evnt.respond error_messages[:user_not_in_voice_channel] if evnt.user.voice_channel.nil? && user
        evnt.respond error_messages[:user_not_connected] if !evnt.voice && user
      end

      def disconnect_action
        bot.voice_destroy(evnt.user.voice_channel)
        "Disconnected from voice channel"
      end

      def speak_event
        bot.command :speak do |event|
          @evnt = event
          @message = event.message.content.split(" ")[1..].join(" ")
          @user = find_userdiscord(event.user.id)
          @chat = user.current_chat
          speak_connect_checker_action
          speak_connection_checker_action
          ask_to_speak_action if user && event.user.voice_channel && event.voice && !chat.nil?
        end
      end

      def speak_connect_checker_action
        evnt.respond error_messages[:user_not_logged_in] if user.nil?
        evnt.respond error_messages[:chat_not_found] if user && evnt.user.voice_channel && evnt.voice && chat.nil?
      end

      def speak_connection_checker_action
        evnt.respond error_messages[:user_not_in_voice_channel] if evnt.user.voice_channel.nil? && user
        evnt.respond error_messages[:bot_not_in_voice_channel] if !evnt.voice && user
      end

      def ask_to_speak_action
        Message.create(chat_id: chat.id, content: message, role: "user")
        response = chatter.chat(message, chat.id)
        audio_path = audio_synthesis.synthesize_text(response)
        speak_answer_action(audio_path, response)
      end

      def speak_answer_action(audio_path, response)
        evnt.respond response
        evnt.voice.play_file(audio_path)
        delete_all_voice_files
        "OK"
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
