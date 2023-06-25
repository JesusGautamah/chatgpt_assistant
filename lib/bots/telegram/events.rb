# frozen_string_literal: true

module Bots
  module Telegram
    module Events
      def start_event
        telegram_send_start_message
      end

      def help_event
        help_messages.each { |m| send_message m, msg.chat.id }
      end

      def hist_event
        hist_allowed?

        user.chat_history.each do |m|
          send_message m, msg.chat.id
        end
      rescue NoChatSelectedError, UserNotLoggedInError, NoMessagesFoundedError, AccountNotVerifiedError => e
        send_message e.message, msg.chat.id
      end

      def list_event
        list_allowed?

        send_message common_messages[:chat_list], msg.chat.id
        chats_str = ""
        user.chats.each_with_index { |c, i| chats_str += "Chat #{i + 1} - #{c.title}\n" }
        send_message chats_str, msg.chat.id
      rescue NoChatsFoundedError, UserNotLoggedInError, AccountNotVerifiedError => e
        send_message e.message, msg.chat.id
      end

      def confirm_account_event
        raise UserNotLoggedInError if user.nil?

        user_info = msg.text.split("/* ").last
        name, token = user_info.split(":")
        send_message "#{name} - #{token}", msg.chat.id
        if user_confirmed?
          send_message success_messages[:account_confirmed], msg.chat.id
        else
          send_message error_messages[:account_not_confirmed], msg.chat.id
        end
      rescue UserNotLoggedInError => e
        send_message e.message, msg.chat.id
      end

      def login_event
        raise UserLoggedInError if user

        user_info = msg.text.split("/").last
        email, password = user_info.split(":")
        authenticate_user(email, password)
      rescue UserNotFoundError, WrongPasswordError, UserLoggedInError => e
        send_message e.message, msg.chat.id
      end

      def register_event
        user_info = msg.text.split("/").last
        email, password = register_allowed?(user_info)
        name = msg.from.first_name || "Anonymous"

        RegisterJob.perform_async(email, password, name, visitor.telegram_id)
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
        common_allowed?
        NewChatJob.perform_async(msg.text.split("/").last, user.id, msg.chat.id)
      rescue UserNotLoggedInError, AccountNotVerifiedError => e
        send_message e.message, msg.chat.id
      end

      def select_chat_event
        common_allowed?
        title = msg.text.split("/").last
        chat = user.chat_by_title(title)
        select_allowed?(chat)

        send_message success_messages[:chat_selected], msg.chat.id
      rescue UserNotLoggedInError, ChatNotFoundError, AccountNotVerifiedError => e
        send_message e.message, msg.chat.id
      end

      def audio_event
        audio_allowed?
        user_audio = transcribe_file(telegram_audio_url)
        message = Message.new(content: user_audio[:text], chat_id: user.current_chat_id, role: "user")
        raise MessageNotSavedError unless message.save

        ai_response = telegram_process_ai_voice(user_audio[:file])
        telegram_send_voice_message(voice: ai_response[:voice], text: ai_response[:text])
        delete_file ai_response[:voice]
      rescue UserNotLoggedInError, NoChatSelectedError, MessageNotSavedError, AccountNotVerifiedError => e
        send_message e.message, msg.chat.id
      end

      def telegram_chat_event
        common_allowed?
        chat_if_exists
      rescue UserNotLoggedInError, AccountNotVerifiedError => e
        send_message e.message, msg.chat.id
      end
    end
  end
end
