# frozen_string_literal: true

module Bots
  module Discord
    module Actions
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

      def start_action
        fields = %w[login start help new_chat sl_chat ask list hist connect disconnect speak]

        values_hash = {
          login: "Account login, use: #{discord_prefix}login email:password",
          start: "Start the bot, use: #{discord_prefix}start",
          help: "Show this message, use: #{discord_prefix}help",
          new_chat: "Create a new chat, use: #{discord_prefix}new_chat chat_name",
          sl_chat: "Select a chat, use: #{discord_prefix}sl_chat chat_name",
          ask: "Ask a question, use: #{discord_prefix}ask question",
          list: "List all chats, use: #{discord_prefix}list",
          hist: "Show chat history, use: #{discord_prefix}hist",
          connect: "Connect to voice channel, use: #{discord_prefix}connect",
          disconnect: "Disconnect from voice channel, use: #{discord_prefix}disconnect",
          speak: "Speak in voice channel, use: #{discord_prefix}speak question"
        }

        embed = Discordrb::Webhooks::Embed.new(
          title: "Hello, #{evnt.user.name}!",
          description: "I'm ChatGPT Assistant, see my commands below:",
          color: "00FF00",
          fields: fields.map { |field| { name: field, value: values_hash[field.to_sym] } }
        )
        evnt.respond nil, false, embed
      end

      def help_action
        start_action
      end

      def list_action
        chats = user.chats

        embed = Discordrb::Webhooks::Embed.new(
          title: "Hello, #{evnt.user.name}!",
          description: "Your chats:",
          color: "00FF00",
          fields: chats.map { |field| { name: field.title, value: field.actor || "No prompt" } }
        )

        evnt.respond nil, false, embed
      end

      def hist_action
        messages = Message.where(chat_id: chat.id).order(:created_at)
        messages.each { |m| send_message "#{m.role} - #{m.content}\n#{m.created_at.strftime("%d/%m/%Y %H:%M")}" }
        "This is the end of the chat history"
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
        actor = AwesomeChatgptActors::Actor.new(role: actor_name, language: config.language) if actor_name
        chat = Chat.new(user_id: user.id, status: 0, title: title, actor: actor_name, prompt: actor.prompt) if actor
        chat = Chat.new(user_id: user.id, status: 0, title: title) unless actor
        return send_message "Something went wrong", msg.chat.id unless chat

        chat.save ? chat_created_message(chat) : send_message(error_messages[:chat_creation])
      end

      def discord_created(chat)
        evnt.respond "Intructions sended to actor:\n#{chat.prompt}" unless chat.actor.nil?
        evnt.respond success_messages[:chat_created] if evnt.present?
      end
    end
  end
end
