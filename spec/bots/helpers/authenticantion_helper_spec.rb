# frozen_string_literal: true

RSpec.describe ChatgptAssistant::AuthenticationHelper do
  let(:helper_class) { Class.new { include ChatgptAssistant::AuthenticationHelper } }
  let(:helper_instance) { helper_class.new }

  describe '#valid_password?' do
    let(:password) { 'password' }
    let(:salt) { BCrypt::Engine.generate_salt }
    let(:hash) { BCrypt::Engine.hash_secret(password, salt) }

    it 'returns true for valid password' do
      expect(helper_instance.valid_password?(password, hash, salt)).to be true
    end

    it 'returns false for invalid password' do
      expect(helper_instance.valid_password?('wrong_password', hash, salt)).to be false
    end
  end

  describe '#telegram_user_auth' do
    let(:email) { 'test@example.com' }
    let(:password) { 'password' }
    let(:telegram_id) { '123456789' }
    let(:visitor) { double('Visitor', telegram_id: telegram_id) }
    let(:user) { double('User', email: email, password_hash: BCrypt::Password.create(password), password_salt: BCrypt::Engine.generate_salt) }

    before do
      allow(helper_instance).to receive(:find_visitor).with(telegram_id: telegram_id).and_return(visitor)
      allow(helper_instance).to receive(:find_user).with(email: email).and_return(user)
      allow(helper_instance).to receive(:where_user).with(telegram_id: telegram_id).and_return(nil)
    end

    it 'returns "wrong password" when password is nil' do
      expect(helper_instance.telegram_user_auth(email, nil, telegram_id)).to eq('wrong password')
    end

    it 'returns "something went wrong" when visitor access is nil' do
      allow(helper_instance).to receive(:find_visitor).with(telegram_id: telegram_id).and_return(nil)
      expect(helper_instance.telegram_user_auth(email, password, telegram_id)).to eq('something went wrong')
    end

    it 'returns "user not found" when user is nil' do
      allow(helper_instance).to receive(:find_user).with(email: email).and_return(nil)
      expect(helper_instance.telegram_user_auth(email, password, telegram_id)).to eq('user not found')
    end

    it 'returns "wrong password" when password is invalid' do
      expect(helper_instance.telegram_user_auth(email, 'wrong_password', telegram_id)).to eq('wrong password')
    end

    it 'returns user email when authentication is successful' do
      allow(helper_instance).to receive(:telegram_user_access).with(visitor, user).and_return(email)
      expect(helper_instance.telegram_user_auth(email, password, telegram_id)).to eq(email)
    end
  end

  describe '#telegram_user_access' do
    let(:telegram_id) { '123456789' }
    let(:visitor) { double('Visitor', telegram_id: telegram_id) }
    let(:user_email) { 'test@example.com' }
    let(:user) { double('User', email: user_email) }

    before do
      allow(helper_instance).to receive(:where_user).with(telegram_id: telegram_id).and_return(nil)
    end

    it 'sets new_access telegram_id and return email' do
      expect(user).to receive(:update).with(telegram_id: telegram_id)
      expect(helper_instance.telegram_user_access(visitor, user)).to eq(user_email)
    end

    it 'updates existing_access telegram_id and return email' do
      existing_access = double('User', telegram_id: '987654321')
      allow(helper_instance).to receive(:where_user).with(telegram_id: telegram_id).and_return(existing_access)
      expect(existing_access).to receive(:update).with(telegram_id: telegram_id)
      expect(helper_instance.telegram_user_access(visitor, user)).to eq(user_email)
    end
  end
end