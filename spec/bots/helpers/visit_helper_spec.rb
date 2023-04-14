# frozen_string_literal: true

RSpec.describe ChatgptAssistant::VisitHelper do
  let(:visitor) { double("Visitor") }
  let(:chat_id) { 123 }
  let(:user_id) { 456 }
  let(:msg) { double("Telegram Message", from: double("Telegram User", first_name: "John")) }
  let(:evnt) { double("Discord Event", user: double("Discord User", name: "Jane")) }

  describe "#telegram_visited?" do
    context "when visitor with given chat_id and name exists" do
      it "returns the visitor" do
        allow(Visitor).to receive(:find_by).with(telegram_id: chat_id, name: msg.from.first_name).and_return(visitor)
        expect(subject.telegram_visited?(chat_id)).to eq(visitor)
      end
    end

    context "when visitor with given chat_id and name does not exist" do
      it "creates a new visitor and returns it" do
        allow(Visitor).to receive(:find_by).with(telegram_id: chat_id, name: msg.from.first_name).and_return(nil)
        allow(Visitor).to receive(:create).with(telegram_id: chat_id, name: msg.from.first_name).and_return(visitor)
        expect(subject.telegram_visited?(chat_id)).to eq(visitor)
      end
    end
  end

  describe "#discord_visited?" do
    context "when visitor with given user_id and name exists" do
      it "returns the visitor" do
        allow(Visitor).to receive(:find_by).with(discord_id: user_id, name: evnt.user.name).and_return(visitor)
        expect(subject.discord_visited?(user_id)).to eq(visitor)
      end
    end

    context "when visitor with given user_id and name does not exist" do
      it "creates a new visitor and returns it" do
        allow(Visitor).to receive(:find_by).with(discord_id: user_id, name: evnt.user.name).and_return(nil)
        allow(Visitor).to receive(:create).with(discord_id: user_id, name: evnt.user.name).and_return(visitor)
        expect(subject.discord_visited?(user_id)).to eq(visitor)
      end
    end
  end
end
