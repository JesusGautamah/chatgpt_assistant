# frozen_string_literal: true

RSpec.describe User, type: :model do
  let(:visitor) { create(:visitor) }

  subject { build(:user, telegram_id: visitor.telegram_id, discord_id: visitor.discord_id) }

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_length_of(:email).is_at_most(100) }
    it { should validate_presence_of(:password) }
  end

  describe "associations" do
    it { should belong_to(:tel_visitor).class_name("Visitor") }
    it { should belong_to(:dis_visitor).class_name("Visitor") }
    it { should have_many(:chats) }
  end

  describe "defaults" do
    it "has the correct default values" do
      expect(subject.current_chat_id).to eq 0
      expect(subject.open_chats).to eq 0
      expect(subject.closed_chats).to eq 0
      expect(subject.total_chats).to eq 0
      expect(subject.total_messages).to eq 0
    end
  end

  describe "methods" do
    let(:user) { create(:user) }
    it "has to run before_save encrypt_password" do
      expect(user).to receive(:encrypt_password)
      user.update(password: "123")
    end

    describe "#current_chat" do
      let(:user) { create(:user) }
      let(:chat) { create(:chat, user: user) }

      it "returns the current chat" do
        chat
        user.update(current_chat_id: chat.id)
        expect(user.current_chat).to eq(chat)
      end
    end

    describe "#last_chat" do
      let(:user) { create(:user) }
      let(:chat) { create(:chat, user: user) }

      it "returns the last chat" do
        chat
        expect(user.last_chat).to eq(chat)
      end
    end

    describe "#chat_by_title" do
      let(:user) { create(:user) }
      let(:chat) { create(:chat, user: user) }

      it "returns the chat with the corresponding title" do
        chat
        expect(user.chat_by_title(chat.title)).to eq(chat)
      end
    end

    describe "#encrypt_password" do
      it "encrypts the password" do
        subject.password = "123"
        subject.save
        expect(subject.password_hash).not_to eq("123")
      end
    end

    describe "#tel_user" do
      it "returns the user with the corresponding telegram_id" do
        subject.save
        expect(visitor.tel_user).to eq(subject)
      end
    end

    describe "#dis_user" do
      it "returns the user with the corresponding discord_id" do
        subject.save
        expect(visitor.dis_user).to eq(subject)
      end
    end
  end
end