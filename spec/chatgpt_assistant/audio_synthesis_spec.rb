# frozen_string_literal: true

RSpec.describe ChatgptAssistant::AudioSynthesis do
  let(:config) do
    double("config", openai_api_key: "openai_key", language: "en", mode: "aws", aws_access_key_id: "access_key", aws_secret_access_key: "secret_key",
                     aws_region: "us-east-1")
  end

  describe "#synthesize_text" do
    context "when using IBM mode" do
      let(:config) { double("config", openai_api_key: "openai_key", language: "en", mode: "ibm", ibm_api_key: "ibm_key", ibm_url: "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/123") }
      let(:audio_synthesis) { ChatgptAssistant::AudioSynthesis.new(config) }

      before do
        allow(audio_synthesis).to receive(:synthesize_text_ibm).and_return("voice/ibm-12345.mp3")
      end

      it "calls synthesize_text_ibm method" do
        expect(audio_synthesis).to receive(:synthesize_text_ibm).with("Hello, how are you?")
        audio_synthesis.synthesize_text("Hello, how are you?")
      end
    end

    context "when using AWS mode" do
      let(:audio_synthesis) { ChatgptAssistant::AudioSynthesis.new(config) }

      before do
        allow(audio_synthesis).to receive(:synthesize_text_aws).and_return("voice/aws-12345.mp3")
      end

      it "calls synthesize_text_aws method" do
        expect(audio_synthesis).to receive(:synthesize_text_aws).with("Hello, how are you?")
        audio_synthesis.synthesize_text("Hello, how are you?")
      end
    end
  end

  describe "#synthesize_text_ibm" do
    let(:audio_synthesis) { ChatgptAssistant::AudioSynthesis.new(config) }
    let(:authenticator) { double("authenticator") }
    let(:text_to_speech) { double("text_to_speech") }
    let(:audio_format) { "audio/mp3" }
    let(:audio) { "audio_file" }
    let(:time) { Time.now.to_i }

    before do
      allow(IBMWatson::Authenticators::IamAuthenticator).to receive(:new).and_return(authenticator)
      allow(IBMWatson::TextToSpeechV1).to receive(:new).and_return(text_to_speech)
      allow(File).to receive(:binwrite)
      allow(text_to_speech).to receive(:service_url=)
      allow(text_to_speech).to receive(:synthesize).and_return(double("result", result: audio))
    end

    # it 'calls IBM Watson API to synthesize text into speech and save the file' do
    #   expect(IBMWatson::Authenticators::IamAuthenticator).to receive(:new).with(apikey: config.ibm_api_key).and_return(authenticator)
    #   expect(IBMWatson::TextToSpeechV1).to receive(:new).with(authenticator: authenticator).and_return(text_to_speech)
    #   expect(text_to_speech).to receive(:service_url=).with(config.ibm_url)
    #   expect(text_to_speech).to receive(:synthesize).with(text: 'Hello, how are you?', accept: audio_format, voice: 'en-US_AllisonV3Voice').and_return(double('result', result: audio))
    #   expect(File).to receive(:binwrite).with("voice/ibm-#{time}.mp3", audio)
    #   audio_synthesis.synthesize_text_ibm('Hello, how are you?')
    # end
  end

  describe "#synthesize_text_aws" do
    let(:audio_synthesis) { ChatgptAssistant::AudioSynthesis.new(config) }
    let(:polly_client) { double("polly_client") }
    let(:response) { double("response", audio_stream: double("audio_stream", read: "audio_file")) }
    let(:time) { Time.now.to_i }

    before do
      allow(Aws::Polly::Client).to receive(:new).and_return(polly_client)
      allow(File).to receive(:binwrite)
      allow(polly_client).to receive(:synthesize_speech).and_return(response)
    end

    # it 'calls AWS Polly API to synthesize text into speech and save the file' do
    #   expect(Aws::Polly::Client).to receive(:new).with(
    #     access_key_id: config.aws_access_key_id,
    #     secret_access_key: config.aws_secret_access_key,
    #     region: config.aws_region
    #   ).and_return(polly_client)
    #   expect(polly_client).to receive(:synthesize_speech).with(output_format: 'mp3', text: 'Hello, how are you?', voice_id: 'Joanna', engine: 'neural').and_return(response)
    #   expect(File).to receive(:binwrite).with("voice/aws-#{time}.mp3", response.audio_stream.read)
    #   audio_synthesis.synthesize_text_aws('Hello, how are you?')
    # end
  end
end
