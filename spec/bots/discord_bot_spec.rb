RSpec.describe ChatgptAssistant::DiscordBot do
  let(:config) { ChatgptAssistant::Config.new }
  let(:bot) { ChatgptAssistant::DiscordBot.new(config) }

  describe "#start" do
    it "calls all the necessary events" do
      expect(bot).to receive(:start_event)
      expect(bot).to receive(:login_event)
      expect(bot).to receive(:register_event)
      expect(bot).to receive(:list_event)
      expect(bot).to receive(:hist_event)
      expect(bot).to receive(:help_event)
      expect(bot).to receive(:new_chat_event)
      expect(bot).to receive(:sl_chat_event)
      expect(bot).to receive(:ask_event)
      expect(bot).to receive(:voice_connect_event)
      expect(bot).to receive(:disconnect_event)
      expect(bot).to receive(:speak_event)
      expect(bot).to receive(:private_message_event)
      expect(bot).to receive(:bot_init)

      bot.start
    end
  end
end