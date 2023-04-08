# frozen_string_literal: true

require_relative "helpers/telegram_helper"

module ChatgptAssistant
  # This class is responsible for the telegram bot features
  class TelegramBot < ApplicationBot
    def start
      bot.listen do |message|
        @msg = message
        @visitor = telegram_visited?(@msg.chat.id)
        next unless telegram_text_or_audio?

        text_events if telegram_message_has_text?
        audio_event if telegram_message_has_audio?
      end
    rescue StandardError => e
      Error.create(message: e.message, backtrace: e.backtrace)
      retry
    end

    private

      include TelegramHelper

      attr_accessor :msg, :visitor, :chat, :chat_id

      def text_events
        case msg.text
        when "/start"
          start_event
        when "/help"
          help_event
        when "/hist"
          hist_event
        when "/list"
          list_event
        when "/stop"
          stop_event
        when nil
          nil_event
        else
          action_events
        end
      end

      def start_event
        register_visitor_action("start", visitor.id) unless visitor.tel_user
        register_user_action("start", visitor.tel_user.id) if visitor.tel_user
        telegram_send_start_message
      end

      def help_event
        register_visitor_action("help", visitor.id) unless visitor.tel_user
        register_user_action("help", visitor.tel_user.id) if visitor.tel_user
        help_messages.each { |m| send_message m, msg.chat.id }
      end

      def hist_event
        return not_logged_in_message unless user
        return no_chat_selected_message unless user.current_chat
        return no_messages_founded_message if user.current_chat.messages.count.zero?

        register_user_action("hist", user.id)
        telegram_user_history.each do |m|
          send_message m, msg.chat.id
        end
      end

      def list_event
        return unless valid_for_list_action?

        register_user_action("list", user.id)
        send_message commom_messages[:chat_list], msg.chat.id
        chats_str = ""
        user.chats.each_with_index { |c, i| chats_str += "Chat #{i + 1} - #{c.title}\n" }
        send_message chats_str, msg.chat.id
      end

      def action_events
        return login_event if msg.text.include?("login/")
        return register_event if msg.text.include?("register/")
        return new_chat_event if msg.text.include?("new_chat/")
        return select_chat_event if msg.text.include?("sl_chat/")
        return telegram_chat_event unless telegram_actions?

        invalid_command_error_message
      end

      def login_event
        register_visitor_action("login", visitor.id) unless visitor.tel_user
        user_info = msg.text.split("/").last
        email, password = user_info.split(":")

        case telegram_user_auth(email, password, msg.chat.id)
        when "user not found"

          user_not_found_error_message
        when "wrong password"
          wrong_password_error_message
        when find_user(email: email).email
          user_logged_in_message
        end
      end

      def register_event
        register_visitor_action("register", visitor.id)
        user_info = msg.text.split("/").last
        email, password = user_info.split(":")
        registered_email = telegram_user_create visitor.id, email, password
        registered_email == email ? user_created_message : user_creation_error_message
      end

      def new_chat_event
        return not_logged_in_message unless user

        register_user_action("new_chat", user.id)
        telegram_create_chat
      end

      def select_chat_event
        return not_logged_in_message unless user

        register_user_action("select_chat", user.id)
        title = msg.text.split("/").last
        chat = user.chat_by_title(title)
        return chat_not_found_message unless chat

        user.update(current_chat_id: chat.id)
        send_message success_messages[:chat_selected], msg.chat.id
      end

      def stop_event
        register_event_action("stop", visitor.id) unless visitor.tel_user
        register_user_action("stop", visitor.tel_user.id) if visitor.tel_user
        send_message commom_messages[:stop], msg.chat.id
        bot.api.leave_chat(chat_id: msg.chat.id)
      end

      def nil_event
        register_event_action("nil", visitor.id) unless visitor.tel_user
        register_user_action("nil", visitor.tel_user.id) if visitor.tel_user
        send_message error_messages[:nil], msg.chat.id
      end

      def audio_event
        return not_logged_in_message unless user
        return no_chat_selected_message if user.current_chat_id.nil?

        register_user_action("audio", user.id)
        user_audio = transcribe_file(telegram_audio_url)
        message = Message.new(content: user_audio[:text], chat_id: user.current_chat_id, role: "user")
        if message.save
          ai_response = telegram_process_ai_voice(user_audio[:file])
          telegram_send_voice_message(voice: ai_response[:voice], text: ai_response[:text])
        else
          send_message error_messages[:message_creation_error], msg.chat.id
        end
      end
  end
end
