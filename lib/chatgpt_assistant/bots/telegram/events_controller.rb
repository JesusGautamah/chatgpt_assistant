# frozen_string_literal: true

module ChatgptAssistant
  module Bots
    module Telegram
      module EventsController
        def auth_events
          return login_event if msg.text.include?("login/")
          return register_event if msg.text.include?("register/")
          return sign_out_event if msg.text.include?("sign_out/")
          return confirm_account_event if msg.text.include?("confirm/* ")
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
      end
    end
  end
end
