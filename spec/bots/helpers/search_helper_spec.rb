# frozen_string_literal: true

RSpec.describe ChatgptAssistant::SearchHelper do
  let(:visitor) { create(:visitor) }
  let(:config) { ChatgptAssistant::Config.new }
  let(:dummy_class) { ChatgptAssistant::TelegramBot.new(config) }

  describe "#find_visitor" do
    context "when telegram_id is provided" do
      it "returns the visitor with the corresponding telegram_id" do
        expect(dummy_class.find_visitor(telegram_id: visitor.telegram_id)).to eq(visitor)
      end
    end

    context "when discord_id is provided" do
      it "returns the visitor with the corresponding discord_id" do
        expect(dummy_class.find_visitor(discord_id: visitor.discord_id)).to eq(visitor)
      end
    end

    context "when neither telegram_id nor discord_id is provided" do
      it "returns nil" do
        expect(dummy_class.find_visitor).to be_nil
      end
    end
  end

  describe "#find_user" do
    let(:user_tel) { create(:user, telegram_id: 1239, discord_id: 5672, email: "test@tel.com") }
    let(:user_disc) { create(:user, telegram_id: 1231, discord_id: 5673, email: "test@disc.com") }
    let(:user_mail) { create(:user, telegram_id: 1232, discord_id: 5678, email: "test@mail.com") }
    context "when telegram_id is provided" do
      it "returns the user with the corresponding telegram_id" do
        expect(dummy_class.find_user(telegram_id: user_tel.telegram_id)).to eq(user_tel)
      end
    end

    context "when discord_id is provided" do
      it "returns the user with the corresponding discord_id" do
        expect(dummy_class.find_user(discord_id: user_disc.discord_id)).to eq(user_disc)
      end
    end

    context "when email is provided" do
      it "returns the user with the corresponding email" do
        expect(dummy_class.find_user(email: user_mail.email)).to eq(user_mail)
      end
    end

    context "when neither telegram_id, discord_id, nor email is provided" do
      it "returns nil" do
        expect(dummy_class.find_user).to be_nil
      end
    end
  end

  describe "#where_user" do
    let(:user_tel) { create(:user, telegram_id: 1240, discord_id: 5622, email: "testw@tel.com") }
    let(:user_disc) { create(:user, telegram_id: 1241, discord_id: 5623, email: "testw@disc.com") }
    let(:user_mail) { create(:user, telegram_id: 1242, discord_id: 5628, email: "testw@mail.com") }
    context "when telegram_id is provided" do
      it "returns the users with the corresponding telegram_id" do
        expect(dummy_class.where_user(telegram_id: user_tel.telegram_id)).to eq([user_tel])
      end
    end

    context "when discord_id is provided" do
      it "returns the users with the corresponding discord_id" do
        expect(dummy_class.where_user(discord_id: user_disc.discord_id)).to eq([user_disc])
      end
    end

    context "when email is provided" do
      it "returns the users with the corresponding email" do
        expect(dummy_class.where_user(email: user_mail.email)).to eq([user_mail])
      end
    end

    context "when neither telegram_id, discord_id, nor email is provided" do
      it "returns an empty array" do
        expect(dummy_class.where_user).to eq(nil)
      end
    end
  end
end
