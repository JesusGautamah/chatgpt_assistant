# frozen_string_literal: true

module ChatgptAssistant
  # Helper for discord
  module DiscordHelper
    def bot
      @bot ||= Discordrb::Commands::CommandBot.new(
        token: discord_token,
        client_id: discord_client_id,
        prefix: discord_prefix
      )
    end

    def start_action
      send_message commom_messages[:start_helper].gsub("register/", "gpt!register ")
      send_message commom_messages[:start_sec_helper].gsub("login/", "gpt!login ")
    end

    def login_action
      user_email, user_password = message.split(":")
      case discord_user_auth(user_email, user_password, evnt.user.id)
      when "user not found"
        send_message error_messages[:user_not_found]
      when "wrong password"
        puts "wrong password"
        send_message error_messages[:wrong_password]
      when find_user(email: user_email).email
        send_message success_messages[:user_logged_in]
      end
    end

    def create_user_action(mail, pass)
      id = evnt.user.id
      return send_message(success_messages[:user_created]) if discord_user_create(id, mail, pass)

      send_message(error_messages[:user_not_created])
    end

    def register_action
      user_email = message.split(":")[0]
      user_password = message.split(":")[1]
      return create_user_action(user_email, user_password) if find_user(email: user_email).nil?

      send_message(error_messages[:user_already_exists])
    end

    def list_action
      chats_title = user.chats.map(&:title)
      send_message commom_messages[:chat_list]
      send_message chats_title.join("\n")
    end

    def hist_action
      messages = Message.where(chat_id: chat.id).order(:created_at)
      messages.each { |m| send_message "#{m.role} - #{m.content}\n#{m.created_at.strftime("%d/%m/%Y %H:%M")}" }
      "This is the end of the chat history"
    end

    def help_action
      message = discord_help_message
      send_message message
    end

    def ask_action
      @chat = Chat.where(id: user.current_chat_id).last
      send_message error_messages[:chat_not_found] if chat.nil?
      @message = Message.new(chat_id: chat.id, content: message, role: "user") if chat
      (message.save ? answer_action : send_message(error_messages[:message_not_saved])) if chat
    end

    def private_message_action
      @chat = Chat.where(id: user.current_chat_id).last
      send_message error_messages[:chat_not_found] if chat.nil?
      @message = Message.new(chat_id: chat.id, content: message, role: "user") if chat
      (message.save ? answer_action : send_message(error_messages[:message_not_saved])) if chat
    end

    def sl_chat_action(chat_to_select)
      @chat = user.chat_by_title(chat_to_select)
      send_message error_messages[:chat_not_found] if chat.nil?
      user.update(current_chat_id: chat.id) if chat
      send_message success_messages[:chat_selected] if chat
    end

    def create_chat_action
      title = evnt.message.content.split[1..].join(" ")
      mode = nil
      if title.include? ":"
        mode = title.split(":").last.to_i
        title = title.split(":").first
      end
      actors = AwesomeChatgptActors::CastControl.actors
      return send_message "invalid mode" unless (mode.to_i >= 1 && mode.to_i <= actors.size + 1) || mode.nil?
      return send_message "invalid chat title" if title.nil? || title.empty?
      return send_message "chat title already exists" if user.chat_by_title(title)

      actor_name = actors[mode.to_i - 1] if mode
      actor = AwesomeChatgptActors::Actor.new(prompt_type: actor_name) if actor_name
      chat = Chat.new(user_id: user.id, status: 0, title: title, actor: actor_name, prompt: actor.prompt) if actor
      chat = Chat.new(user_id: user.id, status: 0, title: title) unless actor
      return send_message "Something went wrong", msg.chat.id unless chat

      chat.save ? chat_created_message(chat) : send_message(error_messages[:chat_creation])
    end

    def answer_action
      response = chatter.chat(message.content, chat.id, error_messages[:something_went_wrong])
      send_message response
    end

    def disconnect_checker_action
      send_message error_messages[:user_not_logged_in] if user.nil?
      send_message error_messages[:user_not_in_voice_channel] if evnt.user.voice_channel.nil? && user
      send_message error_messages[:user_not_connected] if !evnt.voice && user
    end

    def discord_user_create(discord_id, email, password)
      user = User.new(discord_id: discord_id, email: email, password: password)
      last_access = find_user(discord_id: discord_id)
      last_access&.update(discord_id: nil)
      user.save
    end
  end
end
