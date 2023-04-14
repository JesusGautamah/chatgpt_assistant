# frozen_string_literal: true

RSpec.describe ChatgptAssistant::Chatter do
  let(:openai_api_key) { ENV.fetch("OPENAI_API_KEY", nil) }
  let(:chatter) { described_class.new(openai_api_key) }

  describe "#chat" do
    context "when the response status is 200 and the json has choices" do
      let(:visitor) { create(:visitor, telegram_id: 1) }
      let(:user) { create(:user, telegram_id: 1) }
      let(:chat) { create(:chat, user: user) }
      let(:message_text) { "Hello!" }
      let(:message) { create(:message, content: message_text, chat: chat, role: "user") }
      let(:chat_id) { 1 }
      let(:error_message) { "I'm sorry, an error occurred." }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(
          double("response", status: 200, body: { choices: [{ message: { content: "Hi!" } }] }.to_json)
        )
      end

      it "returns the bot's response" do
        expect(chatter.chat(message, chat_id, error_message)).not_to be_nil
        expect(chatter.chat(message, chat_id, error_message)).not_to eq("I'm sorry, an error occurred.")
      end

      it "creates a new message with the bot's response" do
        expect { chatter.chat(message, chat_id, error_message) }.to change(Message, :count).by(1)
      end
    end

    context "when the response status is not 200" do
      let(:openai_api_key) { "wrong_key" }
      let(:visitor) { create(:visitor, telegram_id: 1) }
      let(:user) { create(:user, telegram_id: 1) }
      let(:chat) { create(:chat, user: user) }
      let(:message_text) { "Hello!" }
      let(:message) { create(:message, content: message_text, chat: chat, role: "user") }
      let(:chat_id) { 1 }
      let(:error_message) { "I'm sorry, an error occurred." }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(
          double("response", status: 401, body: { error: "Unauthorized" }.to_json)
        )
      end

      it "returns the error message" do
        expect(chatter.chat(message, chat_id, error_message)).to eq("I'm sorry, an error occurred.")
      end
    end

    context "when the json has no choices" do
      let(:message) { "Hello!" }
      let(:chat_id) { 1 }
      let(:error_message) { "I'm sorry, an error occurred." }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(
          double("response", status: 200, body: { choices: [] }.to_json)
        )
      end

      it "returns the no response error message" do
        expect(chatter.chat(message, chat_id, error_message)).to eq("I'm sorry, I didn't understand you. Please, try again.")
      end
    end
  end
end
