# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for synthesize text to speech
  # This class can work with IBM Cloud or AWS Polly for synthesize text into speech
  class AudioSynthesis
    def initialize(config)
      @config = config
      @language = config.language
      classify_mode
    end

    def synthesize_text(text)
      @text = text
      if ibm_mode?
        synthesize_text_ibm
      elsif aws_mode?
        synthesize_text_aws
      elsif azure_mode?
        synthesize_text_azure
      end
    end

    private

      attr_reader :ibm_api_key, :ibm_url, :aws_access_key_id, :aws_secret_access_key, :aws_region,
                  :config, :language, :voice, :azure_speech_url, :azure_speech_key, :text

      def conn(url)
        Faraday.new(url: url)
      end

      def classify_mode
        if ibm_mode?
          @ibm_api_key = config.ibm_api_key
          @ibm_url = config.ibm_url
          @voice = send("#{language}_ibm_voice")
        elsif aws_mode?
          @aws_access_key_id = config.aws_access_key_id
          @aws_secret_access_key = config.aws_secret_access_key
          @aws_region = config.aws_region
          @voice = send("#{language}_aws_voice")
        elsif azure_mode?
          @azure_speech_url = config.azure_speech_url
          @azure_speech_key = config.azure_speech_key
        end
      end

      def synthesize_text_aws
        time = Time.now.to_i
        polly_client = Aws::Polly::Client.new(
          access_key_id: aws_access_key_id,
          secret_access_key: aws_secret_access_key,
          region: aws_region
        )
        response = polly_client.synthesize_speech(
          output_format: "mp3",
          text: text,
          voice_id: voice,
          engine: "neural"
        )

        File.binwrite("voice/aws-#{time}.mp3", response.audio_stream.read)
        "voice/aws-#{time}.mp3"
      end

      def synthesize_text_ibm
        time = Time.now.to_i
        authenticator = IBMWatson::Authenticators::IamAuthenticator.new(
          apikey: ibm_api_key
        )

        text_to_speech = IBMWatson::TextToSpeechV1.new(
          authenticator: authenticator
        )

        text_to_speech.service_url = ibm_url

        audio_format = "audio/mp3"
        audio = text_to_speech.synthesize(
          text: text,
          accept: audio_format,
          voice: voice
        ).result

        File.binwrite("voice/ibm-#{time}.mp3", audio)
        "voice/ibm-#{time}.mp3"
      end

      def synthesize_text_azure
        @voice = send("#{language}_azure_voice")
        time = Time.now.to_i
        headers = {
          "Ocp-Apim-Subscription-Key": azure_speech_key,
          "Content-Type": "application/ssml+xml",
          "X-Microsoft-OutputFormat": "audio-48khz-192kbitrate-mono-mp3",
          "User-Agent": "curl"
        }

        response = conn(azure_speech_url).post do |req|
          req.headers = headers
          req.body = voice
        end

        File.binwrite("voice/azure-#{time}.mp3", response.body)
        "voice/azure-#{time}.mp3"
      end

      def pt_aws_voice
        "Vitoria"
      end

      def en_aws_voice
        "Joanna"
      end

      def pt_ibm_voice
        "pt-BR_IsabelaV3Voice"
      end

      def en_ibm_voice
        "en-US_AllisonV3Voice"
      end

      def pt_azure_voice
        <<~XML
          <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts"
          xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="pt-BR">
          <voice name="pt-BR-AntonioNeural">#{text}</voice>
          </speak>
        XML
      end

      def en_azure_voice
        <<~XML
          <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
          <voice name="en-US-JennyNeural">#{text}</voice>
          </speak>
        XML
      end

      def ibm_mode?
        config.mode == "ibm"
      end

      def aws_mode?
        config.mode == "aws"
      end

      def azure_mode?
        config.mode == "azure"
      end
  end
end
