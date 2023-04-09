# frozen_string_literal: true

module ChatgptAssistant
  # Helper for voice actions
  module DiscordVoiceHelper
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

    def ask_to_speak_action
      Message.create(chat_id: chat.id, content: message, role: "user")
      response = chatter.chat(message, chat.id)
      audio_path = synthesis.synthesize_text(response)
      speak_answer_action(audio_path, response)
    end

    def speak_answer_action(audio_path, response)
      send_message response
      evnt.voice.play_file(audio_path)
      delete_file audio_path
      "OK"
    end

    def discord_voice_bot_connect
      bot.voice_connect(evnt.user.voice_channel) if discord_voice_bot_disconnected?
      discord_voice_bot_connected? ? "Connected to voice channel" : "Error connecting to voice channel"
    end

    def disconnect_action
      bot.voice_destroy(evnt.user.voice_channel)
      "Disconnected from voice channel"
    end
  end
end
