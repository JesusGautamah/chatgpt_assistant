# frozen_string_literal: true

require_relative "helpers/telegram_helper"
require_relative "helpers/telegram_voice_helper"

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
      include TelegramVoiceHelper

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
          raise NilError
        else
          action_events
        end
      rescue NilError => e
        send_message e.message, msg.chat.id
      end

      def start_event
        telegram_send_start_message
      end

      def help_event
        help_messages.each { |m| send_message m, msg.chat.id }
      end

      def hist_event
        raise UserNotLoggedInError if user.nil?
        raise NoChatSelectedError if user.current_chat.nil?
        raise NoMessagesFoundedError if user.current_chat.messages.count.zero?

        user.chat_history.each do |m|
          send_message m, msg.chat.id
        end
      rescue NoChatSelectedError, UserNotLoggedInError, NoMessagesFoundedError => e
        send_message e.message, msg.chat.id
      end

      def list_event
        raise UserNotLoggedInError if user.nil?
        raise NoChatsFoundedError if user.chats.count.zero?

        send_message common_messages[:chat_list], msg.chat.id
        chats_str = ""
        user.chats.each_with_index { |c, i| chats_str += "Chat #{i + 1} - #{c.title}\n" }
        send_message chats_str, msg.chat.id
      rescue NoChatsFoundedError, UserNotLoggedInError => e
        send_message e.message, msg.chat.id
      end

      def action_events
        return auth_events if auth_event?
        return new_chat_event if msg.text.include?("new_chat/")
        return select_chat_event if msg.text.include?("sl_chat/")
        return telegram_chat_event unless telegram_actions?

        raise InvalidCommandError
      rescue InvalidCommandError => e
        send_message e.message, msg.chat.id
      end

      def auth_event?
        msg.text.include?("login/") || msg.text.include?("register/") || msg.text.include?("sign_out/")
      end

      def auth_events
        return login_event if msg.text.include?("login/")
        return register_event if msg.text.include?("register/")
        return sign_out_event if msg.text.include?("sign_out/")
      end

      def login_event
        raise UserLoggedInError if user

        user_info = msg.text.split("/").last
        email, password = user_info.split(":")
        case telegram_user_auth(email, password, msg.chat.id)
        when "user not found"
          raise UserNotFoundError
        when "wrong password"
          raise WrongPasswordError
        when email
          user_logged_in_message
        end
      rescue UserNotFoundError, WrongPasswordError, UserLoggedInError => e
        send_message e.message, msg.chat.id
      end

      def register_event
        user_info = msg.text.split("/").last
        raise NoRegisterInfoError if user_info.nil?
        raise UserLoggedInError if user

        email, password = user_info.split(":")
        raise NoRegisterInfoError if email.nil? || password.nil?

        RegisterJob.perform_async(email, password, visitor.telegram_id)
      rescue NoRegisterInfoError, UserLoggedInError => e
        send_message e.message, msg.chat.id
      end

      def sign_out_event
        raise UserNotLoggedInError if user.nil?

        user.update(telegram_id: nil)
        send_message success_messages[:user_logged_out], msg.chat.id
      rescue UserNotLoggedInError => e
        send_message e.message, msg.chat.id
      end

      def new_chat_event
        raise UserNotLoggedInError if user.nil?

        NewChatJob.perform_async(msg.text.split("/").last, user.id, msg.chat.id)
      rescue UserNotLoggedInError => e
        send_message e.message, msg.chat.id
      end

      def select_chat_event
        raise UserNotLoggedInError if user.nil?

        title = msg.text.split("/").last
        chat = user.chat_by_title(title)
        raise ChatNotFoundError if chat.nil?

        raise ChatNotFoundError unless user.update(current_chat_id: chat.id)

        send_message success_messages[:chat_selected], msg.chat.id
      rescue UserNotLoggedInError, ChatNotFoundError => e
        send_message e.message, msg.chat.id
      end

      def audio_event
        raise UserNotLoggedInError if user.nil?
        raise NoChatSelectedError if user.current_chat.nil?

        user_audio = transcribe_file(telegram_audio_url)
        message = Message.new(content: user_audio[:text], chat_id: user.current_chat_id, role: "user")
        raise MessageNotSavedError unless message.save

        ai_response = telegram_process_ai_voice(user_audio[:file])
        telegram_send_voice_message(voice: ai_response[:voice], text: ai_response[:text])
        delete_file ai_response[:voice]
      rescue UserNotLoggedInError, NoChatSelectedError, MessageNotSavedError => e
        send_message e.message, msg.chat.id
      end
  end
end
