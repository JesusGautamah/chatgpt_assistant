# frozen_string_literal: true

RSpec.describe Visitor, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:platform) }
  it { should define_enum_for(:platform).with_values([:telegram, :discord]) }

  describe "#tel_user" do
    let(:visitor) { create(:visitor, telegram_id: "123") }
    let(:user) { create(:user, telegram_id: "123") } 

    it "returns the user with the corresponding telegram_id" do
      user
      expect(visitor.tel_user).to eq(user)
    end
  end

  describe "#discord_user" do
    let(:visitor) { create(:visitor, discord_id: "123") }
    let(:user) { create(:user, discord_id: "123") }

    it "returns the user with the corresponding discord_id" do
      user
      expect(visitor.dis_user).to eq(user)
    end
  end
end
