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

    attr_reader :message, :evnt

    def bot
      @bot ||= Discordrb::Commands::CommandBot.new(
        token: discord_token,
        client_id: discord_client_id,
        prefix: discord_prefix
      )
    end

    def voice_bot
      @voice_bot ||= Discordrb::Bot.new(
        token: discord_token,
        client_id: discord_client_id
      )
    end

    def start_logs
      logger.log("Starting Discord bot")
      logger.log("Discord Prefix: #{discord_prefix}")
    end

    def start_event
      bot.command :start do |event|
        event.respond commom_messages[:start]
        event.respond commom_messages[:start_helper].gsub("register/", "gpt!register ")
        event.respond commom_messages[:start_sec_helper].gsub("login/", "gpt!login ")
      end
      logger.log("Start Event Configured")
    end

    def login
      user_email = message.split(":")[0]
      user_password = message.split(":")[1]
      case auth_userdiscord(user_email, user_password, evnt.user.id)
      when "user not found"
        evnt.respond error_messages[:user_not_found]
      when "wrong password"
        evnt.respond error_messages[:wrong_password]
      when find_useremail(user_email)
        evnt.respond success_messages[:user_logged_in]
      end
    end

    def login_event
      bot.command :login do |event|
        @message = event.message.content.split(" ")[1]
        @evnt = event
        message.nil? ? event.respond(commom_messages[:login]) : login
      end
      logger.log("Login Event Configured")
    end

    def register
      user_email = message.split(":")[0]
      user_password = message.split(":")[1]
      if find_useremail(user_email).nil?
        logger.log("Creating user #{user_email}")
        if discord_user_create(evnt.user.id, user_email, user_password, evnt.user.username)
          evnt.respond success_messages[:user_created]
        else
          evnt.respond error_messages[:user_not_created]
        end
      else
        evnt.respond error_messages[:email]
      end
    end

    def register_event
      bot.command :register do |event|
        @message = event.message.content.split(" ")[1]
        @evnt = event
        if message.nil?
          event.respond commom_messages[:register]
        else
          register
        end
      end
      logger.log("Register Event Configured")
    end

    def list_event
      bot.command :list do |event|
        user = User.find_by(discord_id: event.user.id)
        if user
          chats = Chat.where(user_id: user.id)
          if chats.empty?
            event.respond error_messages[:chat_not_found]
          else
            chats = chats.map(&:title)
            event.respond commom_messages[:chat_list]
            event.respond chats.join("\n")
          end
        else
          event.respond error_messages[:user_not_logged_in]
        end
      end
      logger.log("List Event Configured")
    end

    def help_event
      bot.command :help do |event|
        message = help_messages.join("\n").gsub(" /", " gpt!")
                               .gsub("register/", "gpt!register ")
                               .gsub("login/", "gpt!login ")
                               .gsub("new_chat/", "gpt!new_chat/")
                               .gsub("sl_chat/", "gpt!sl_chat/")
        event.respond message
      end
      logger.log("Help Event Configured")
    end

    def new_chat_event
      bot.command :new_chat do |event|
        user = User.find_by(discord_id: event.user.id)
        chat_title = event.message.content.split(" ")[1..].join(" ")
        if user
          chat = Chat.new(user_id: user.id, title: chat_title, status: 0)
          if chat.save
            user.update(current_chat_id: chat.id)
            event.respond success_messages[:chat_created]
          else
            event.respond error_messages[:chat_creation]
          end
        else
          event.respond error_messages[:user_not_logged_in]
        end
      end
      logger.log("New Chat Event Configured")
    end

    def sl_chat_event
      bot.command :sl_chat do |event|
        chat_to_select = event.message.content.split(" ")[1..].join(" ")
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.find_by(title: chat_to_select, user_id: user.id)
          if chat
            event.respond success_messages[:chat_selected]
          else
            event.respond error_messages[:chat_not_found]
          end
        else
          event.respond error_messages[:user_not_logged_in]
        end
      end
      logger.log("SL Chat Event Configured")
    end

    def ask_event
      bot.command :ask do |event|
        message = event.message.content.split(" ")[1..].join(" ")
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            Message.create(chat_id: chat.id, content: message, role: "user")
            response = chatter.chat(message, chat.id)
            event.respond response
          else
            event.respond error_messages[:chat_not_found]
          end
        else
          event.respond error_messages[:user_not_logged_in]
        end
      end
      logger.log("Ask Event Configured")
    end

    def voice_connect_event
      bot.command :connect do |event|
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            if event.user.voice_channel
              bot.voice_connect(event.user.voice_channel)
              "Connected to voice channel"
            else
              event.respond error_messages[:user_not_in_voice_channel]
            end
          else
            event.respond error_messages[:chat_not_found]
          end
        else
          event.respond error_messages[:user_not_logged_in]
        end
      end
      logger.log("Voice Connect Event Configured")
    end

    def disconnect_event
      bot.command :disconnect do |event|
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            event.voice.destroy if event.user.voice_channel && event.voice
          else
            event.respond error_messages[:chat_not_found]
          end
        else
          event.respond error_messages[:user_not_logged_in]
        end
      end
    end

    def speak_event
      bot.command :speak do |event|
        message = event.message.content.split(" ")[1..].join(" ")
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            Message.create(chat_id: chat.id, content: message, role: "user")
            response = chatter.chat(message, chat.id)
            audio_path = audio_synthesis.synthesize_text(response)
            event.respond response
            event.voice.play_file(audio_path)
            delete_all_voice_files
          else
            event.respond error_messages[:chat_not_found]
          end
        else
          event.respond error_messages[:user_not_logged_in]
        end
      end
    end

    def bot_init
      logger.log("Discord bot started")
      at_exit { bot.stop }
      begin
        bot.run nil
      rescue StandardError
        start
      end
    end
  end
end
