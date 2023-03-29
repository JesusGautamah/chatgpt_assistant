# frozen_string_literal: true
module ChatgptAssistant
  # This is the AudioRecognition class
  class AudioRecognition
    def initialize(openai_api_key)
      @conn = Faraday.new(url: "https://api.openai.com/") do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
      @logger = ChatterLogger.new
      @openai_api_key = openai_api_key
    end

    def download_audio(audio_url)
      logger.log("DOWNLOADING AUDIO FROM TELEGRAM")
      @time = Time.now.to_i
      audio_conn = Faraday.new(url: audio_url)
      File.open("voice/audio-#{time}.oga", "wb") do |file|
        file.write(audio_conn.get.body)
      end

      FFMPEG::Movie.new("voice/audio-#{time}.oga").transcode("voice/audio-#{time}.mp3")
      File.delete("voice/audio-#{time}.oga")
    end

    def header
      {
        "Content-Type": "multipart/form-data",
        "Authorization": "Bearer #{openai_api_key}"
      }
    end

    def payload
      {
        "file": Faraday::UploadIO.new("voice/audio-#{time}.mp3", "audio/mp3"),
        "model": "whisper-1"
      }
    end

    def transcribe_audio(audio_url)
      @audio_url = audio_url
      download_audio(audio_url)
      response = conn.post("v1/audio/transcriptions", payload, header)
      logger.log("RESPONSE FROM OPENAI API AUDIO TRANSCRIPTION")
      JSON.parse(response.body)["text"]
    end

    private

    attr_reader :conn, :openai_api_key, :logger, :audio_url, :time, :ibm_api_key, :ibm_url
  end
end
