# frozen_string_literal: true

module Bots
  module Telegram
    module VoiceActions
      def telegram_audio_info
        bot.api.get_file(file_id: telegram_audio.file_id)
      end

      def telegram_audio_url
        "https://api.telegram.org/file/bot#{telegram_token}/#{telegram_audio_info["result"]["file_path"]}"
      end

      def telegram_audio
        msg.audio || msg.voice
      end

      def telegram_process_ai_voice(user_audio)
        ai_text = chatter.chat(user_audio["text"], user.current_chat_id, error_messages[:something_went_wrong])
        ai_voice = synthesis.synthesize_text(ai_text)
        {
          voice: ai_voice,
          text: ai_text
        }
      end

      def telegram_send_voice_message(voice: nil, text: nil)
        messages = parse_message text, 4096
        bot.api.send_voice(chat_id: msg.chat.id, voice: Faraday::UploadIO.new(voice, "audio/mp3"))
        messages.each { |message| send_message message, msg.chat.id }
      end
    end
  end
end
