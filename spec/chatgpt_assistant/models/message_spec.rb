# frozen_string_literal: true

RSpec.describe Message, type: :model do
  describe "validations" do
    it { should validate_presence_of(:content) }
  end

  describe "associations" do
    it { should belong_to(:chat) }
  end
end
