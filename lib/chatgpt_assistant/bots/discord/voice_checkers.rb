# frozen_string_literal: true

module ChatgptAssistant
  module Bots
    module Discord
      module VoiceCheckers
        def voice_connect_checker_action
          send_message error_messages[:user_not_logged_in] if user.nil?
          send_message error_messages[:chat_not_found] if user && chat.nil?
        end

        def voice_connection_checker_action
          send_message error_messages[:user_not_in_voice_channel] if evnt.user.voice_channel.nil? && user
          send_message error_messages[:bot_already_connected] if evnt.voice && user
        end

        def speak_connect_checker_action
          send_message error_messages[:user_not_logged_in] if user.nil?
          send_message error_messages[:chat_not_found] if user && evnt.user.voice_channel && evnt.voice && chat.nil?
        end

        def speak_connection_checker_action
          send_message error_messages[:user_not_in_voice_channel] if evnt.user.voice_channel.nil? && user
          send_message error_messages[:bot_not_in_voice_channel] if !evnt.voice && user
        end

        def disconnect_checker_action
          send_message error_messages[:user_not_logged_in] if user.nil?
          send_message error_messages[:user_not_in_voice_channel] if evnt.user.voice_channel.nil? && user
          send_message error_messages[:user_not_connected] if !evnt.voice && user
        end
      end
    end
  end
end
