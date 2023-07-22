# frozen_string_literal: true

module ChatgptAssistant
  module Bots
    module Telegram
      module Validations
        def telegram_actions?
          msg.text.include?("new_chat/") || msg.text.include?("sl_chat/") || msg.text.include?("login/") || msg.text.include?("register/")
        end

        def telegram_text_or_audio?
          msg.respond_to?(:text) || msg.respond_to?(:audio) || msg.respond_to?(:voice)
        end

        def telegram_message_has_text?
          msg.text.present?
        end

        def telegram_message_has_audio?
          msg.audio.present? || msg.voice.present?
        end

        def telegram_visited?(chat_id)
          return unless msg

          visitor = Visitor.find_by(telegram_id: chat_id, name: msg.from.first_name)
          if visitor.nil?
            Visitor.create(telegram_id: chat_id, name: msg.from.first_name)
          else
            visitor
          end
        end

        def visitor_user?
          visitor&.tel_user.nil?
        end

        def valid_for_list_action?
          send_message(chat_id: msg.chat.id, text: error_messages[:user_not_logged_in]) if user.nil?
          send_message(chat_id: msg.chat.id, text: error_messages[:account_not_verified]) unless user.active?
          send_message(chat_id: msg.chat.id, text: error_messages[:chat_not_found]) if user.chats.count.zero? && user.active?
          !user.nil? && user.active? && user.chats.count.positive?
        end

        def auth_event?
          msg.text.include?("login/") || msg.text.include?("register/") || msg.text.include?("sign_out/") || msg.text.include?("confirm/* ")
        end

        def user_confirmed?(name, token)
          user.name == name && user.confirm_account(token)
        end
      end
    end
  end
end
