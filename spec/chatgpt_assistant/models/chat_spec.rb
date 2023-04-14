# frozen_string_literal: true

RSpec.describe Chat, type: :model do
  let(:user) { FactoryBot.create(:user) }
  subject { FactoryBot.create(:chat, user: user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to have_many(:messages) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end