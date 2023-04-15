# frozen_string_literal: true

module ChatgptAssistant
  # Helper for messenger
  module MessengerHelper
    def chat_success(chat_id)
      user_message = Message.new(chat_id: chat_id, content: msg.text, role: "user")
      if user_message&.save
        text = chatter.chat(msg.text, chat_id, error_messages[:something_went_wrong])
        mess = parse_message(text, 4096)
        mess.each { |m| send_message m, msg.chat.id }
      else
        send_message error_messages[:something_went_wrong], msg.chat.id
      end
    end

    def respond_with_success(chat)
      user.update(current_chat_id: chat.id)
      send_message success_messages[:chat_created]
    end

    def parse_message(message, max_length)
      if message.length > max_length
        array = message.scan(/.{1,#{max_length}}/) if max_length.positive?
        array = ["Something went wrong! Try again later"] if max_length <= 0
      else
        array = [message]
      end
      array
    end

    def send_message(text, chat_id = nil)
      @send_message = bot.respond_to?(:api) ? telegram_send_message(text, chat_id) : discord_send_message(text)
    end

    def telegram_send_message(text, chat_id)
      messages = parse_message(text, 4096)
      messages.each { |m| bot.api.send_message(chat_id: chat_id, text: m) }
    end

    def discord_send_message(text)
      messages = parse_message(text, 2000)
      messages.each { |m| evnt.respond m }
    end

    def discord_help_message
      help_messages.join("\n").gsub(" /", discord_prefix)
                   .gsub("register/", "#{discord_prefix}register ")
                   .gsub("login/", "#{discord_prefix}login ")
                   .gsub("new_chat/", "#{discord_prefix}new_chat/")
                   .gsub("sl_chat/", "#{discord_prefix}sl_chat/")
    end

    def user_logged_message
      user.update(telegram_id: msg.chat.id)
      bot.api&.send_message(chat_id: msg.chat.id, text: success_messages[:user_logged_in])
      evnt&.respond success_messages[:user_logged_in] if evnt.present?
    end

    def invalid_command_error_message
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:invalid_command])
      evnt&.respond error_messages[:invalid_command]
    end

    def user_not_found_error_message
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:user_not_found]) if bot.api.present?
      evnt&.respond error_messages[:user_not_found] if evnt.present?
    end

    def user_created_message
      bot.api&.send_message(chat_id: msg.chat.id, text: success_messages[:user_created]) if bot.api.present?
      evnt&.respond success_messages[:user_created] if evnt.present?
    end

    def user_creation_error_message
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:user_creation]) if bot.api.present?
      evnt&.respond error_messages[:user_creation] if evnt.present?
    end

    def chat_created_message(chat)
      user&.update(current_chat_id: chat.id)
      return telegram_created(chat) if bot.respond_to?(:api)

      discord_created(chat)
    end

    def telegram_created(chat)
      bot.api.send_message(chat_id: msg.chat.id, text: "Intructions sended to actor:\n#{chat.prompt}") unless chat.actor.nil?
      bot.api.send_message(chat_id: msg.chat.id, text: "Response from assistant:\n#{chat.messages[1].content}") unless chat.actor.nil?
      bot.api.send_message(chat_id: msg.chat.id, text: success_messages[:chat_created]) if bot.api.present?
    end

    def discord_created(chat)
      evnt.respond "Intructions sended to actor:\n#{chat.prompt}" unless chat.actor.nil?
      evnt.respond "Response from assistant:\n#{chat.messages[1].content}" unless chat.actor.nil?
      evnt.respond success_messages[:chat_created] if evnt.present?
    end

    def not_logged_in_message
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:user_not_logged_in])
      evnt&.respond(error_messages[:user_not_logged_in])
    end

    def wrong_password_error_message
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:password])
      evnt&.respond(error_messages[:password])
    end

    def chat_not_found_message
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:chat_not_found])
      evnt&.respond(error_messages[:chat_not_found])
    end

    def no_chat_selected_message
      bot&.api&.send_message(chat_id: msg.chat.id, text: error_messages[:no_chat_selected])
      evnt&.respond(error_messages[:no_chat_selected])
    end

    def no_messages_founded_message
      bot&.api&.send_message(chat_id: msg.chat.id, text: error_messages[:no_messages_founded])
      evnt&.respond(error_messages[:no_messages_founded])
    end

    def chat_creation_failed_message
      bot&.api&.send_message(chat_id: msg.chat.id, text: error_messages[:chat_creation_failed])
      evnt&.respond(error_messages[:chat_creation_failed])
    end

    def user_logged_in_message
      bot.api&.send_message(chat_id: msg.chat.id, text: success_messages[:user_logged_in])
      evnt&.respond(success_messages[:user_logged_in])
    end
  end
end
