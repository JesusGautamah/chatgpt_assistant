# frozen_string_literal: true

RSpec.describe ChatgptAssistant::SearchHelper do
  let(:visitor) { create(:visitor, telegram_id: 1234, discord_id: 5678) }
  let(:user) { create(:user, telegram_id: 1234, discord_id: 5678, email: 'test@example.com') }

  describe '#find_visitor' do
    context 'when telegram_id is provided' do
      it 'returns the visitor with the corresponding telegram_id' do
        expect(subject.find_visitor(telegram_id: visitor.telegram_id)).to eq(visitor)
      end
    end

    context 'when discord_id is provided' do
      it 'returns the visitor with the corresponding discord_id' do
        expect(subject.find_visitor(discord_id: visitor.discord_id)).to eq(visitor)
      end
    end

    context 'when neither telegram_id nor discord_id is provided' do
      it 'returns nil' do
        expect(subject.find_visitor).to be_nil
      end
    end
  end

  describe '#find_user' do
    context 'when telegram_id is provided' do
      it 'returns the user with the corresponding telegram_id' do
        expect(subject.find_user(telegram_id: user.telegram_id)).to eq(user)
      end
    end

    context 'when discord_id is provided' do
      it 'returns the user with the corresponding discord_id' do
        expect(subject.find_user(discord_id: user.discord_id)).to eq(user)
      end
    end

    context 'when email is provided' do
      it 'returns the user with the corresponding email' do
        expect(subject.find_user(email: user.email)).to eq(user)
      end
    end

    context 'when neither telegram_id, discord_id, nor email is provided' do
      it 'returns nil' do
        expect(subject.find_user).to be_nil
      end
    end
  end

  describe '#where_user' do
    context 'when telegram_id is provided' do
      it 'returns the users with the corresponding telegram_id' do
        expect(subject.where_user(telegram_id: user.telegram_id)).to eq([user])
      end
    end

    context 'when discord_id is provided' do
      it 'returns the users with the corresponding discord_id' do
        expect(subject.where_user(discord_id: user.discord_id)).to eq([user])
      end
    end

    context 'when email is provided' do
      it 'returns the users with the corresponding email' do
        expect(subject.where_user(email: user.email)).to eq([user])
      end
    end

    context 'when neither telegram_id, discord_id, nor email is provided' do
      it 'returns an empty array' do
        expect(subject.where_user).to eq([])
      end
    end
  end
end