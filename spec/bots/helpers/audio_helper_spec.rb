# frozen_string_literal: true

RSpec.describe ChatgptAssistant::AudioHelper do
  let(:dummy_class) { Class.new { include ChatgptAssistant::AudioHelper } }
  let(:dummy_instance) { dummy_class.new }

  describe "#recognition" do
    let(:openai_api_key) { "some_key" }

    it "creates an instance of ChatgptAssistant::AudioRecognition with openai_api_key" do
      allow(dummy_instance).to receive(:openai_api_key).and_return(openai_api_key)
      expect(ChatgptAssistant::AudioRecognition).to receive(:new).with(openai_api_key)
      dummy_instance.recognition
    end

    # it "memoizes the instance of ChatgptAssistant::AudioRecognition" do
    #   expect(ChatgptAssistant::AudioRecognition).to receive(:new).once.and_return("some_instance")
    #   2.times { dummy_instance.recognition }
    # end
  end

  describe "#synthesis" do
    let(:config) { instance_double("Config") }

    it "creates an instance of ChatgptAssistant::AudioSynthesis with config" do
      allow(dummy_instance).to receive(:config).and_return(config)
      expect(ChatgptAssistant::AudioSynthesis).to receive(:new).with(config)
      dummy_instance.synthesis
    end

    # it "memoizes the instance of ChatgptAssistant::AudioSynthesis" do
    #   expect(ChatgptAssistant::AudioSynthesis).to receive(:new).once.and_return("some_instance")
    #   2.times { dummy_instance.synthesis }
    # end
  end

  describe "#transcribe_file" do
    let(:recognition) { instance_double("ChatgptAssistant::AudioRecognition") }
    let(:url) { "https://example.com/some_file.wav" }

    before do
      allow(dummy_instance).to receive(:recognition).and_return(recognition)
    end

    it "calls transcribe_audio on the recognition instance" do
      expect(recognition).to receive(:transcribe_audio).with(url)
      dummy_instance.transcribe_file(url)
    end
  end
end