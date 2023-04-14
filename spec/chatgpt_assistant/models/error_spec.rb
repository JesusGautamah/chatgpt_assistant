# frozen_string_literal: true

RSpec.describe Error, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:backtrace) }
  end

  # describe 'associations' do
  #   it { should belong_to(:user).optional }
  #   it { should belong_to(:chat).optional }
  # end
end