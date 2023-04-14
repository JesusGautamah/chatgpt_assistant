# frozen_string_literal: true

RSpec.describe ChatgptAssistant::ValidationHelper do
  let(:user) { double("User", id: 1, current_chat_id: 1, chats: double("Chats", count: 1)) }
  let(:visitor) { double("Visitor", tel_user: nil, dis_user: nil) }
  let(:chat) { double("Chat", id: 1) }
  let(:evnt) { double("Event", user: double("User", voice_channel: true), voice: true, channel: double("Channel", type: 1), message: double("Message", content: "#{discord_prefix}login")) }
  let(:discord_prefix) { "!" }

  describe "#valid_for_list_action?" do
    it "returns false if user is nil" do
      expect(valid_for_list_action?).to eq(false)
    end

    it "returns false if user has no chats" do
      allow(user).to receive_message_chain(:chats, :count).and_return(0)
      expect(valid_for_list_action?).to eq(false)
    end

    it "returns true if user is not nil and has chats" do
      expect(valid_for_list_action?).to eq(true)
    end
  end

  describe "#chat_if_exists" do
    it "returns chat_success message if chat exists" do
      allow(Chat).to receive(:find_by).with(user_id: user.id, id: user.current_chat_id).and_return(chat)
      expect(chat_if_exists).to eq(chat_success(chat.id))
    end

    it "returns no_chat_selected_message if chat does not exist" do
      allow(Chat).to receive(:find_by).with(user_id: user.id, id: user.current_chat_id).and_return(nil)
      expect(chat_if_exists).to eq(no_chat_selected_message)
    end
  end

  describe "#visitor_user?" do
    it "returns true if visitor has no telegram or discord user" do
      expect(visitor_user?).to eq(true)
    end

    it "returns false if visitor has a telegram or discord user" do
      allow(visitor).to receive(:tel_user).and_return(true)
      expect(visitor_user?).to eq(false)
    end
  end

  describe "#discord_voice_bot_disconnected?" do
    it "returns true if user is not nil, event user has a voice channel, event voice is false, and chat is not nil" do
      expect(discord_voice_bot_disconnected?).to eq(true)
    end

    it "returns false if any of the conditions are not met" do
      allow(evnt).to receive(:voice).and_return(false)
      expect(discord_voice_bot_disconnected?).to eq(false)
    end
  end

  describe "#discord_voice_bot_connected?" do
    it "returns true if user is not nil, event user has a voice channel, event voice is true, and chat is not nil" do
      expect(discord_voice_bot_connected?).to eq(true)
    end

    it "returns false if any of the conditions are not met" do
      allow(evnt).to receive(:voice).and_return(false)
      expect(discord_voice_bot_connected?).to eq(false)
    end
  end

  describe "#discord_next_action?" do
    it "returns true if event channel type is not 1" do
      allow(evnt).to receive_message_chain(:channel, :type).and_return(0)
      expect(discord_next_action?).to eq(true)
    end

    it "returns true if event message content includes any of the actions" do
      expect(discord_next_action?).to eq(true)
    end

    it "returns false if event message content does not include any of the actions" do
      allow(evnt).to receive_message_chain(:message, :content).and_return("#{discord_prefix}invalid_action")
      expect(discord_next_action?).to eq(false)
    end
  end
end
