# frozen_string_literal: true

module ChatgptAssistant
  # Helper for messenger
  module MessengerHelper
    def chat_success(chat_id)
      Message.create(chat_id: chat_id, content: msg.text, role: "user")
      text = chatter.chat(msg.text, chat_id)
      mess = parse_message(text, 4096)
      mess.each { |m| send_message m, msg.chat.id }
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
      @send_message = bot.api.present? ? telegram_send_message(text, chat_id) : discord_send_message(text)
    end

    def telegram_send_message(text, chat_id)
      bot.api.send_message(chat_id: chat_id, text: text)
    end

    def discord_send_message(text)
      evnt.respond text
    end

    def user_logged_message
      register_user_action("login", user.id)
      user.update(telegram_id: msg.chat.id)
      bot.api&.send_message(chat_id: msg.chat.id, text: success_messages[:user_logged_in])
      evnt&.respond success_messages[:user_logged_in] if evnt.present?
    end

    def invalid_command_error_message
      register_user_action("invalid_command", user.id) if user
      register_visitor_action("invalid_command", visitor.id) if visitor&.tel_user.nil?
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:invalid_command])
      evnt&.respond error_messages[:invalid_command]
    end

    def user_not_found_error_message
      register_visitor_action("error: user not found", visitor.id)
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:user_not_found]) if bot.api.present?
      evnt&.respond error_messages[:user_not_found] if evnt.present?
    end

    def user_created_message
      register_visitor_action("user_created", visitor.id)
      bot.api&.send_message(chat_id: msg.chat.id, text: success_messages[:user_created]) if bot.api.present?
      evnt&.respond success_messages[:user_created] if evnt.present?
    end

    def user_creation_error_message
      register_visitor_action("error: user creation", visitor.id)
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:user_creation]) if bot.api.present?
      evnt&.respond error_messages[:user_creation] if evnt.present?
    end

    def chat_created_message(chat)
      register_user_action("chat_created", user.id) if user
      user&.update(current_chat_id: chat.id)
      bot.api&.send_message(chat_id: msg.chat.id, text: success_messages[:chat_created]) if bot.api.present?
    end

    def not_logged_in_message
      register_visitor_action("error: not logged in", visitor.id) if visitor_user?
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:user_not_logged_in])
      evnt&.respond(error_messages[:user_not_logged_in])
    end

    def wrong_password_error_message
      register_visitor_action("error: wrong password", visitor.id) if visitor_user?
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:password])
      evnt&.respond(error_messages[:password])
    end

    def chat_not_found_message
      register_visitor_action("error: visitors cant select chat", visitor.id) if visitor_user?
      register_user_action("error: chat not found", user.id) if user
      bot.api&.send_message(chat_id: msg.chat.id, text: error_messages[:chat_not_found])
      evnt&.respond(error_messages[:chat_not_found])
    end

    def no_chat_selected_message
      register_visitor_action("error: visitors cant select chat", visitor.id) if visitor_user?
      register_user_action("error: no chat selected", user.id) if user
      bot&.api&.send_message(chat_id: msg.chat.id, text: error_messages[:no_chat_selected])
      evnt&.respond(error_messages[:no_chat_selected])
    end

    def no_messages_founded_message
      register_visitor_action("error: visitors cant view the chat history", visitor.id) if visitor_user?
      register_user_action("error: no messages founded", user.id) if user
      bot&.api&.send_message(chat_id: msg.chat.id, text: error_messages[:no_messages_founded])
      evnt&.respond(error_messages[:no_messages_founded])
    end

    def chat_creation_failed_message
      register_visitor_action("error: chat creation failed", visitor.id) if visitor_user?
      register_user_action("error: chat creation failed", user.id) if user
      bot&.api&.send_message(chat_id: msg.chat.id, text: error_messages[:chat_creation_failed])
      evnt&.respond(error_messages[:chat_creation_failed])
    end

    def user_logged_in_message
      register_visitor_action("user_logged_in", visitor.id) if visitor
      bot.api&.send_message(chat_id: msg.chat.id, text: success_messages[:user_logged_in])
      evnt&.respond(success_messages[:user_logged_in])
    end
  end
end
