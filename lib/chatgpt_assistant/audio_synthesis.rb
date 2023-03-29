# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for synthesize text to speech
  # This class can work with IBM Cloud or AWS Polly for synthesize text into speech
  class AudioSynthesis
    def initialize(config)
      @config = config
      @openai_api_key = config.openai_api_key
      @conn = faraday_instance
      @logger = ChatterLogger.new
      classify_mode
    end

    def synthesize_text(text)
      if ibm_mode?
        synthesize_text_ibm(text)
      elsif aws_mode?
        synthesize_text_aws(text)
      end
    end

    private

    attr_reader :openai_api_key, :ibm_api_key, :ibm_url, :aws_access_key_id, :aws_secret_access_key, :aws_region, :config, :logger

    def faraday_instance
      Faraday.new(url: "https://api.openai.com/") do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def classify_mode
      if ibm_mode?
        @ibm_api_key = config.ibm_api_key
        @ibm_url = config.ibm_url
      elsif aws_mode?
        @aws_access_key_id = config.aws_access_key_id
        @aws_secret_access_key = config.aws_secret_access_key
        @aws_region = config.aws_region
      end
    end

    def synthesize_text_aws(text)
      time = Time.now.to_i
      logger.log("SYNTHESIZING TEXT WITH AWS POLLY")
      @time = Time.now.to_i
      polly_client = Aws::Polly::Client.new(
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key,
        region: aws_region
      )
      response = polly_client.synthesize_speech(
        output_format: "mp3",
        text: text,
        voice_id: "Vitoria",
        engine: "neural"
      )

      File.open("voice/aws-#{time}.mp3", "wb") do |file|
        file.write(response.audio_stream.read)
      end
      "voice/aws-#{time}.mp3"
    end

    def synthesize_text_ibm(text)
      time = Time.now.to_i
      logger.log("SYNTHESIZING TEXT WITH IBM WATSON")
      authenticator = IBMWatson::Authenticators::IamAuthenticator.new(
        apikey: ibm_api_key
      )

      text_to_speech = IBMWatson::TextToSpeechV1.new(
        authenticator: authenticator
      )

      text_to_speech.service_url = ibm_url

      voice = "pt-BR_IsabelaV3Voice"
      audio_format = "audio/mp3"
      audio = text_to_speech.synthesize(
        text: text,
        accept: audio_format,
        voice: voice
      ).result

      File.open("voice/ibm-#{time}.mp3", "wb") do |audio_file|
        audio_file.write(audio)
      end
      "voice/ibm-#{time}.mp3"
    end

    def ibm_mode?
      config.mode == "ibm"
    end

    def aws_mode?
      config.mode == "aws"
    end
  end
end
