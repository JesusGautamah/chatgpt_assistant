# frozen_string_literal: true

RSpec.describe ChatgptAssistant::AudioHelper do
  let(:config) {ChatgptAssistant::Config.new}
  let(:helper_bot) { ChatgptAssistant::TelegramBot.new(config) }

  describe "#recognition" do
    let(:openai_api_key) { "some_key" }

    it "creates an instance of ChatgptAssistant::AudioRecognition with openai_api_key" do
      allow(helper_bot).to receive(:openai_api_key).and_return(openai_api_key)
      expect(ChatgptAssistant::AudioRecognition).to receive(:new).with(openai_api_key)
      helper_bot.recognition
    end

    it "memoizes the instance of ChatgptAssistant::AudioRecognition" do
      expect(ChatgptAssistant::AudioRecognition).to receive(:new).once.and_return("some_instance")
      2.times { helper_bot.recognition }
    end
  end

  describe "#synthesis" do

    it "creates an instance of ChatgptAssistant::AudioSynthesis with config" do
      allow(helper_bot).to receive(:config).and_return(config)
      expect(ChatgptAssistant::AudioSynthesis).to receive(:new).with(config)
      helper_bot.synthesis
    end

    it "memoizes the instance of ChatgptAssistant::AudioSynthesis" do
      expect(ChatgptAssistant::AudioSynthesis).to receive(:new).once.and_return("some_instance")
      2.times { helper_bot.synthesis }
    end
  end

  describe "#transcribe_file" do
    let(:recognition) { instance_double("ChatgptAssistant::AudioRecognition") }
    let(:url) { "https://example.com/some_file.wav" }

    before do
      allow(helper_bot).to receive(:recognition).and_return(recognition)
    end

    it "calls transcribe_audio on the recognition instance" do
      expect(recognition).to receive(:transcribe_audio).with(url)
      helper_bot.transcribe_file(url)
    end
  end
end
