# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to handle the discord bot
  class DiscordBot < ApplicationBot
    def start
      start_logs
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

    def bot
      @bot ||= Discordrb::Commands::CommandBot.new(
        token: discord_token,
        client_id: discord_client_id,
        prefix: discord_prefix
      )
    end

    def start_logs
      logger.log("Starting Discord bot")
      logger.log("Discord Prefix: #{discord_prefix}")
    end

    def start_event
      bot.command :start do |event|
        @evnt = event
        @user = event.user
        start_action
      end
      logger.log("Start Event Configured")
    end

    def start_action
      logger.log("USER: #{user.username} - #{user.id}\n MESSAGE: #{event.message.content}")
      evnt.respond commom_messages[:start]
      evnt.respond commom_messages[:start_helper].gsub("register/", "gpt!register ")
      evnt.respond commom_messages[:start_sec_helper].gsub("login/", "gpt!login ")
    end

    def login_event
      bot.command :login do |event|
        @message = event.message.content.split(" ")[1]
        @evnt = event
        message.nil? ? event.respond(commom_messages[:login]) : login_action
      end
      logger.log("Login Event Configured")
    end

    def login_action
      user_email = message.split(":")[0]
      user_password = message.split(":")[1]
      case auth_userdiscord(user_email, user_password, evnt.user.id)
      when "user not found"
        logger.log("User not found: #{user_email}")
        evnt.respond error_messages[:user_not_found]
      when "wrong password"
        logger.log("Wrong password: #{user_email}")
        evnt.respond error_messages[:wrong_password]
      when find_useremail(user_email)
        logger.log("User logged in: #{user_email}")
        evnt.respond success_messages[:user_logged_in]
      end
    end

    def register_event
      bot.command :register do |event|
        @message = event.message.content.split(" ")[1]
        @evnt = event
        message.nil? ? event.respond(commom_messages[:register]): register_action
      end
      logger.log("Register Event Configured")
    end

    def register_action
      user_email = message.split(":")[0]
      user_password = message.split(":")[1]
      find_useremail(user_email).nil? ? create_user_action(user_email, user_password) : evnt.respond(error_messages[:user_already_exists])
    end

    def create_user_action(mail, pass)
      logger.log("Creating user #{mail}")
      id = evnt.user.id
      name = evnt.user.username
      discord_user_create(id, mail, pass, name) ? evnt.respond(success_messages[:user_created]) : evnt.respond(error_messages[:user_not_created])
    end

    def list_event
      bot.command :list do |event|
        @evnt = event
        @user = User.find_by(discord_id: event.user.id)
        event.respond error_messages[:user_not_logged_in] if user.nil?

        @chats = Chat.where(user_id: user.id) if user
        event.respond error_messages[:chat_not_found] if chats.empty? && user

        list_action if user && !chats.empty?
      end
      logger.log("List Event Configured")
    end

    def list_action
      chats_title = chats.map(&:title)
      evnt.respond commom_messages[:chat_list]
      evnt.respond chats_title.join("\n")
    end

    def hist_event
      bot.command :hist do |event|
        @evnt = event
        @user = User.find_by(discord_id: event.user.id)
        event.respond error_messages[:user_not_logged_in] if user.nil?
        title = event.message.content.split(" ")[1 .. -1].join(" ")
        @chat = Chat.find_by(user_id: user.id, title: title) if user
        event.respond error_messages[:chat_not_found] if chat.nil? && user
        hist_action if user && chat
      end
      logger.log("Hist Event Configured")
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
        @evnt  = event
        help_action
      end
      logger.log("Help Event Configured")
    end

    def help_action
      message = help_messages.join("\n").gsub(" /", " gpt!")
                               .gsub("register/", "gpt!register ")
                               .gsub("login/", "gpt!login ")
                               .gsub("new_chat/", "gpt!new_chat/")
                               .gsub("sl_chat/", "gpt!sl_chat/")
      evnt.respond message
    end

    def new_chat_event
      bot.command :new_chat do |event|
        @evnt = event
        @user = User.find_by(discord_id: event.user.id)
        event.respond error_messages[:user_not_logged_in] if user.nil?
        create_chat_action if user
      end
      logger.log("New Chat Event Configured")
    end

    def create_chat_action
      chat_title = event.message.content.split(" ")[1..].join(" ")
      chat = Chat.new(user_id: user.id, title: chat_title, status: 0)
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
        
        @user = User.find_by(discord_id: event.user.id)
        event.respond error_messages[:user_not_logged_in] if user.nil?

        sl_chat_action(chat_to_select) if user
      end
      logger.log("SL Chat Event Configured")
    end

    def sl_chat_action(chat_to_select)
      @chat = Chat.find_by(title: chat_to_select, user_id: user.id)
      evnt.respond error_messages[:chat_not_found] if chat.nil?
      user.update(current_chat_id: chat.id) if chat
      evnt.respond success_messages[:chat_selected] if chat
    end

    def ask_event
      bot.command :ask do |event|
        @evnt = event
        @message = event.message.content.split(" ")[1..].join(" ")
        @user = User.find_by(discord_id: event.user.id)
        event.respond error_messages[:user_not_logged_in] if user.nil?
        ask_action if user
      end
      logger.log("Ask Event Configured")
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
        @user = User.find_by(discord_id: event.user.id)
        @chat = Chat.where(id: user.current_chat_id).last
        event.respond error_messages[:user_not_logged_in] if user.nil?
        event.respond error_messages[:chat_not_found] if user && chat.nil?
        event.respond error_messages[:user_not_in_voice_channel] if event.user.voice_channel.nil? && user
        event.respond error_messages[:bot_already_connected] if event.voice && user
        bot.voice_connect(event.user.voice_channel) if bot_disconnected?
        "Connected to voice channel" if bot_connected?
      end
      logger.log("Voice Connect Event Configured")
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
        @user = User.find_by(discord_id: event.user.id)
        event.respond error_messages[:user_not_logged_in] if user.nil?
        event.respond error_messages[:user_not_in_voice_channel] if event.user.voice_channel.nil? && user
        event.respond error_messages[:user_not_connected] if !event.voice && user
        disconnect_action if user && event.user.voice_channel && event.voice
      end
      logger.log("Disconnect Event Configured")
    end

    def disconnect_action
      logger.log("Disconnecting from voice channel: #{evnt.user.voice_channel.name}")
      bot.voice_destroy(event.user.voice_channel)
      logger.log("Disconnected from voice channel: #{evnt.user.voice_channel.name}")
      "Disconnected from voice channel"
    end

    def speak_event
      bot.command :speak do |event|
        @evnt = event
        @message = event.message.content.split(" ")[1..].join(" ")
        @user = User.find_by(discord_id: event.user.id)
        @chat = Chat.where(id: user.current_chat_id).last
        event.respond error_messages[:user_not_logged_in] if user.nil?
        event.respond error_messages[:user_not_in_voice_channel] if event.user.voice_channel.nil? && user
        event.respond error_messages[:bot_not_in_voice_channel] if !event.voice && user
        event.respond error_messages[:chat_not_found] if user && event.user.voice_channel && event.voice && chat.nil?
        ask_to_speak_action if user && event.user.voice_channel && event.voice && !chat.nil?
      end
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
      logger.log("Discord bot started")
      at_exit { bot.stop }
      bot.run
    rescue StandardError
      start
    end
  end
end
