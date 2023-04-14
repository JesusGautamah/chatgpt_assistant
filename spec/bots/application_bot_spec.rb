# frozen_string_literal: true

RSpec.describe ChatgptAssistant::ApplicationBot do
  let(:config) { double("config", language: "en", openai_api_key: "API_KEY", telegram_token: "TELEGRAM_TOKEN", discord_token: "DISCORD_TOKEN", discord_client_id: "DISCORD_CLIENT_ID", discord_prefix: "PREFIX", db_connection: "DATABASE_CONNECTION", mode: "MODE") }
  let(:bot) { ChatgptAssistant::ApplicationBot.new(config) }
  let(:chatter) { double("Chatter") }

  describe "#initialize" do
    it "initializes with the correct instance variables" do
      expect(bot.openai_api_key).to eq("API_KEY")
      expect(bot.telegram_token).to eq("TELEGRAM_TOKEN")
      expect(bot.discord_token).to eq("DISCORD_TOKEN")
      expect(bot.discord_client_id).to eq("DISCORD_CLIENT_ID")
      expect(bot.discord_prefix).to eq("PREFIX")
      expect(bot.database).to eq("DATABASE_CONNECTION")
      expect(bot.mode).to eq("MODE")
      expect(bot.common_messages).to be_a(Hash)
      expect(bot.error_messages).to be_a(Hash)
      expect(bot.success_messages).to be_a(Hash)
      expect(bot.help_messages).to be_a(Array)
    end
  end

  describe "#chatter" do
    before do
      allow(ChatgptAssistant::Chatter).to receive(:new).with("API_KEY").and_return(chatter)
    end

    it "initializes a Chatter instance with the correct API key" do
      expect(bot.chatter).to eq(chatter)
    end
  end
end
