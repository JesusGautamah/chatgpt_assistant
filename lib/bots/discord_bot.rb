# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to handle the discord bot
  class DiscordBot < ApplicationBot
    def bot
      @bot ||= Discordrb::Commands::CommandBot.new(
        token: discord_token,
        client_id: discord_client_id,
        prefix: discord_prefix,
      )
    end

    def voice_bot
      @voice_bot ||= Discordrb::Bot.new(
        token: discord_token,
        client_id: discord_client_id
      )
    end

    def start
      logger.log('Starting Discord bot')
      logger.log("Discord Prefix: #{discord_prefix}") 

      bot.command :start do |event|
        event.respond default_msg.commom_messages[:start]
        event.respond default_msg.commom_messages[:start_helper].gsub("register/", "gpt!register ")
        event.respond default_msg.commom_messages[:start_sec_helper].gsub("login/", "gpt!login ")
      end
      logger.log('Start Event Configured')

      bot.command :login do |event|
        message_content = event.message.content.split(' ')[1]
        if message_content.nil?
          event.respond default_msg.commom_messages[:login]
        else
          user_email = message_content.split(':')[0]
          user_password = message_content.split(':')[1]
          if User.find_by(email: user_email).nil?
            event.respond default_msg.error_messages[:email]
          else
            user = User.find_by(email: user_email)
            last_access = User.find_by(discord_id: event.user.id)
            if user.password == user_password
              if user && last_access != user
                last_access.update(discord_id: nil) if last_access
                user.update(discord_id: event.user.id)
              end
              event.respond default_msg.success_messages[:user_logged_in]
            else
              event.respond default_msg.error_messages[:password]
            end
          end
        end
      end
      logger.log('Login Event Configured')

      bot.command :register do |event|
        message_content = event.message.content.split(' ')[1]
        if message_content.nil?
          event.respond default_msg.commom_messages[:register]
        else
          user_email = message_content.split(':')[0]
          user_password = message_content.split(':')[1]
          if User.find_by(email: user_email).nil?
            logger.log event.user.username
            logger.log event.user.id
            user = User.new(email: user_email, password: user_password, name: event.user.username, discord_id: event.user.id)
            if user.save
              event.respond default_msg.success_messages[:user_created]
            else
              event.respond default_msg.error_messages[:user_not_created]
              event.respond user.errors.full_messages
            end
          else
            event.respond default_msg.error_messages[:email]
          end
        end
      end
      logger.log('Register Event Configured')

      bot.command :list do |event|
        user = User.find_by(discord_id: event.user.id)
        if user
          chats = Chat.where(user_id: user.id)
          if chats.empty?
            event.respond default_msg.error_messages[:chat_not_found]
          else
            chats = chats.map { |chat| chat.title }
            event.respond default_msg.commom_messages[:chat_list]
            event.respond chats.join("\n")
          end
        else
          event.respond default_msg.error_messages[:user_not_logged_in]
        end
      end
      logger.log('List Event Configured')

      bot.command :help do |event|
        message = default_msg.help_messages.join("\n").gsub(" /", " gpt!").
                                                       gsub("register/", "gpt!register ").
                                                       gsub("login/", "gpt!login ").
                                                       gsub("new_chat/", "gpt!new_chat/").
                                                       gsub("sl_chat/", "gpt!sl_chat/")
        event.respond message
      end
      logger.log('Help Event Configured')

      bot.command :new_chat do |event|
        user = User.find_by(discord_id: event.user.id)
        chat_title = event.message.content.split(' ')[1.. -1].join(' ')
        if user
          chat = Chat.new(user_id: user.id, title: chat_title, status: 0)
          if chat.save
            user.update(current_chat_id: chat.id)
            event.respond default_msg.success_messages[:chat_created]
          else
            event.respond default_msg.error_messages[:chat_creation]
          end
        else
          event.respond default_msg.error_messages[:user_not_logged_in]
        end
      end
      logger.log('New Chat Event Configured')

      bot.command :sl_chat do |event|
        chat_to_select = event.message.content.split(' ')[1.. -1].join(' ')
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.find_by(title: chat_to_select, user_id: user.id)
          if chat
            event.respond default_msg.success_messages[:chat_selected]
          else
            event.respond default_msg.error_messages[:chat_not_found]
          end
        else
          event.respond default_msg.error_messages[:user_not_logged_in]
        end
      end
      logger.log('SL Chat Event Configured')

      bot.command :ask do |event|
        message = event.message.content.split(' ')[1.. -1].join(' ')
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            Message.create(chat_id: chat.id, content: message, role: 'user')
            response = chatter.chat(message, chat.id)
            event.respond response
          else
            event.respond default_msg.error_messages[:chat_not_found]
          end
        else
          event.respond default_msg.error_messages[:user_not_logged_in]
        end
      end

      bot.command :connect do |event|
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            unless event.user.voice_channel
              event.respond default_msg.error_messages[:user_not_in_voice_channel]
            else
              bot.voice_connect(event.user.voice_channel)
              "Connected to voice channel"
            end
          else
            event.respond default_msg.error_messages[:chat_not_found]
          end
        else
          event.respond default_msg.error_messages[:user_not_logged_in]
        end
      end

      bot.command :disconnect do |event|
        user = User.find_by(discord_id: event.user.id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            if event.user.voice_channel && event.voice
              event.voice.destroy
            end
          else
            event.respond default_msg.error_messages[:chat_not_found]
          end
        else
          event.respond default_msg.error_messages[:user_not_logged_in]
        end
      end

      bot.command :speak do |event|
        message = event.message.content.split(' ')[1.. -1].join(' ')
        user = User.find_by(discord_id: event.user. id)
        if user
          chat = Chat.where(id: user.current_chat_id).last
          if chat
            Message.create(chat_id: chat.id, content: message, role: 'user')
            response = chatter.chat(message, chat.id)
            audio_path = audio_synthesis.synthesize_text(response)
            event.respond response
            event.voice.play_file(audio_path)
            # delete all files in voice folder, this is not a rails project
            folder = 'voice/'
            Dir.glob(folder + '*').each do |file|
              next if file == '.keep' || file == 'voice/.keep'
              File.delete(file)
            end
            "Audio Played Successfully"
          else
            event.respond default_msg.error_messages[:chat_not_found]
          end
        else
          event.respond default_msg.error_messages[:user_not_logged_in]
        end
      end

      
      logger.log('Discord bot started')
      at_exit { bot.stop }
      bot.run nil rescue start 
    end
  end
end