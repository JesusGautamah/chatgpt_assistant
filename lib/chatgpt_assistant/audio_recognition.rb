# frozen_string_literal: true

module ChatgptAssistant
  # This is the AudioRecognition class
  class AudioRecognition
    def initialize(openai_api_key)
      time = Time.now.to_i
      @dl_file_name = "voice/audio-#{time}.oga"
      @file_name = "voice/audio-#{time}.mp3"
      @conn = Faraday.new(url: "https://api.openai.com/") do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
      @openai_api_key = openai_api_key
    end

    def transcribe_audio(audio_url)
      download_audio(audio_url)
      @response = conn.post("v1/audio/transcriptions", payload, header)
      transcribed_file_json
    end

    private

      attr_reader :conn, :time,
                  :response, :dl_file_name, :file_name,
                  :ibm_api_key, :ibm_url, :openai_api_key

      def download_audio(audio_url)
        audio_conn = Faraday.new(url: audio_url)
        File.binwrite(dl_file_name, audio_conn.get.body)
        FFMPEG::Movie.new(dl_file_name).transcode(file_name)
        File.delete(dl_file_name)
      end

      def header
        {
          "Content-Type": "multipart/form-data",
          Authorization: "Bearer #{openai_api_key}"
        }
      end

      def payload
        {
          file: Faraday::UploadIO.new(file_name, "audio/mp3"),
          model: "whisper-1"
        }
      end

      def transcribed_file_json
        {
          file: file_name,
          text: JSON.parse(response.body)["text"]
        }
      end
  end
end
