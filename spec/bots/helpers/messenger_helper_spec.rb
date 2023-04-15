# frozen_string_literal: true

RSpec.describe ChatgptAssistant::MessengerHelper do
  let(:config) { ChatgptAssistant::Config.new }
  let(:helper) { ChatgptAssistant::TelegramBot.new(config) }
  let(:msg) { double("msg", text: "Hello", chat: double("chat", id: chat_id)) }
  let(:error_message) { "Something went wrong! Try again later" }
  let(:user) { create(:user) }
  let(:chat) { create(:chat, user: user) }
  let(:chat_id) { chat.id }

  describe "#chat_success" do
    context "when user message is saved successfully" do
      before do
        allow_any_instance_of(Message).to receive(:save).and_return(true)
        allow(helper).to receive(:chatter).and_return(double("chatter", chat: "Hello, World!"))
        allow(helper).to receive(:parse_message).and_return(["Hello,", "World!"])
        allow(helper).to receive(:send_message)
      end

      it "creates a new message with user's chat_id, content and role" do
        user.update(current_chat_id: chat.id)
        helper.instance_variable_set(:@msg, msg)
        expect(Message).to receive(:new).with(chat_id: chat_id, content: msg.text, role: "user")
        helper.chat_success(chat_id)
      end

      it "calls chatter.chat with user's message, chat_id and error message" do
        helper.instance_variable_set(:@msg, msg)
        expect(helper.chatter).to receive(:chat).with(msg.text, chat_id, helper.error_messages[:something_went_wrong])
        helper.chat_success(chat_id)
      end

      it "calls parse_message with the response from chatter.chat" do
        helper.instance_variable_set(:@msg, msg)
        expect(helper).to receive(:parse_message).with("Hello, World!", 4096).and_return(["Hello,", "World!"])
        helper.chat_success(chat_id)
      end

      it "calls send_message with each message from parse_message and chat_id" do
        helper.instance_variable_set(:@msg, msg)
        expect(helper).to receive(:send_message).with("Hello,", chat_id)
        expect(helper).to receive(:send_message).with("World!", chat_id)
        helper.chat_success(chat_id)
      end
    end

    context "when user message is not saved successfully" do
      before do
        allow_any_instance_of(Message).to receive(:save).and_return(false)
        allow(helper).to receive(:send_message)
      end

      it "calls send_message with error message and chat_id" do
        helper.instance_variable_set(:@msg, msg)
        expect(helper).to receive(:send_message).with(helper.error_messages[:something_went_wrong], chat_id)
        helper.chat_success(chat_id)
      end
    end
  end

  describe "#respond_with_success" do
    before do
      allow(helper).to receive(:user).and_return(user)
      allow(helper).to receive(:send_message)
    end

    it "updates user's current_chat_id with chat's id" do
      expect(user).to receive(:update).with(current_chat_id: chat.id)
      helper.respond_with_success(chat)
    end

    it "calls send_message with success message" do
      expect(helper).to receive(:send_message).with(helper.success_messages[:chat_created])
      helper.respond_with_success(chat)
    end
  end

  describe "#parse_message" do
    it "returns an array with message if message length is less than or equal to max_length" do
      expect(helper.parse_message("Hello, World!", 20)).to eq(["Hello, World!"])
    end

    it "splits message into an array of strings with max_length characters if message length is greater than max_length" do
      expect(helper.parse_message("Hello, World!", 5)).to eq(["Hello", ", Wor", "ld!"])
    end

    it "returns an array with error message if max_length is less than or equal to 0" do
      expect(helper.parse_message("Hello, World!", 0)).to eq(["Something went wrong! Try again later"])
      expect(helper.parse_message("Hello, World!", -1)).to eq(["Something went wrong! Try again later"])
    end
  end

  describe "#send_message" do
    let(:text) { "Hello, World!" }
    let(:chat_id) { 1 }

    context "when bot responds to :api" do
      let(:bot) { double("bot", api: double("api")) }

      before do
        allow(helper).to receive(:bot).and_return(bot)
        allow(helper).to receive(:telegram_send_message)
      end

      it "calls telegram_send_message with text and chat_id" do
        expect(helper).to receive(:telegram_send_message).with(text, chat_id)
        helper.send_message(text, chat_id)
      end
    end
  end
end
