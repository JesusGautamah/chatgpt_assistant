# frozen_string_literal: true

RSpec.describe ChatgptAssistant do
  it "has a version number" do
    expect(ChatgptAssistant::VERSION).not_to be nil
  end

  let(:mode) { "telegram" }
  let(:config) { instance_double(ChatgptAssistant::Config) }
  let(:telegram_bot) { instance_double(ChatgptAssistant::TelegramBot) }
  let(:discord_bot) { instance_double(ChatgptAssistant::DiscordBot) }

  before do
    allow(ChatgptAssistant::Config).to receive(:new).and_return(config)
  end

  describe "#start" do
    context "when mode is telegram" do
      let(:mode) { "telegram" }

      before do
        allow(subject).to receive(:telegram_mode?).and_return(true)
        allow(ChatgptAssistant::TelegramBot).to receive(:new).with(config).and_return(telegram_bot)
      end

      it "starts the telegram bot", vcr: { cassette_name: "telegram_bot", once: true } do
        expect(telegram_bot).to receive(:start)
        subject::Main.new(mode).start
      end
    end

    context "when mode is discord" do
      let (:mode) { "discord" }

      before do
        allow(subject).to receive(:discord_mode?).and_return(true)
        allow(ChatgptAssistant::DiscordBot).to receive(:new).with(config).and_return(discord_bot)
      end

      it "starts the discord bot", vcr: { cassette_name: "discord_bot", once: true } do
        expect(discord_bot).to receive(:start)
        subject::Main.new(mode).start
      end
    end

    context "when mode is invalid" do
      let(:mode) { "invalid" }

      it "raises an error", vcr: { cassette_name: "telegram_bot", once: true } do
        expect { subject::Main.new(mode).start }.to raise_error("Invalid mode")
      end
    end
  end
end
