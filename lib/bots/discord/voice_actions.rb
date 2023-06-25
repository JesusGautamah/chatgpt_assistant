# frozen_string_literal: true


module Bots
  module Discord
    module VoiceActions
      def ask_to_speak_action
        Message.create(chat_id: chat.id, content: message, role: "user", discord_message_id: evnt.message.id)
        response = chatter.chat(message, chat.id, error_messages[:something_went_wrong])
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
end
