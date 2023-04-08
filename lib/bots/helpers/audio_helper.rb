# frozen_string_literal: true

module ChatgptAssistant
  # Helper for audio
  module AudioHelper
    def recognition
      @recognition ||= AudioRecognition.new(openai_api_key)
    end

    def synthesis
      @synthesis ||= AudioSynthesis.new(config)
    end

    def transcribe_file(url)
      recognition.transcribe_audio(url)
    end
  end
end
