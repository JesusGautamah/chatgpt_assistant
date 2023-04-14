# frozen_string_literal: true

RSpec.describe ChatgptAssistant::DiscordHelper do
  let(:helper) { Class.new { include ChatgptAssistant::DiscordHelper }.new }

  describe '#bot' do
    it 'returns a Discordrb::Commands::CommandBot instance' do
      expect(helper.bot).to be_a(Discordrb::Commands::CommandBot)
    end
  end

  describe '#start_action' do
    it 'sends start messages' do
      expect(helper).to receive(:send_message).twice
      helper.start_action
    end
  end

  describe '#login_action' do
    let(:evnt) { double('event', user: double('user', id: 1)) }
    let(:user) { double('user', email: 'user@example.com') }
    before { allow(helper).to receive(:message).and_return('user@example.com:password') }

    context 'when user is not found' do
      before { allow(helper).to receive(:discord_user_auth).and_return('user not found') }

      it 'sends an error message' do
        expect(helper).to receive(:send_message).with('User not found')
        helper.login_action
      end
    end

    context 'when password is wrong' do
      before { allow(helper).to receive(:discord_user_auth).and_return('wrong password') }

      it 'sends an error message' do
        expect(helper).to receive(:send_message).with('Wrong password')
        helper.login_action
      end
    end

    context 'when user is found and password is correct' do
      before { allow(helper).to receive(:find_user).and_return(user) }
      before { allow(helper).to receive(:discord_user_auth).and_return(user.email) }

      it 'sends a success message' do
        expect(helper).to receive(:send_message).with('User logged in')
        helper.login_action
      end
    end
  end

  describe '#create_user_action' do
    let(:evnt) { double('event', user: double('user', id: 1)) }

    context 'when user creation is successful' do
      before { allow(helper).to receive(:discord_user_create).and_return(true) }

      it 'sends a success message' do
        expect(helper).to receive(:send_message).with('User created')
        helper.create_user_action('user@example.com', 'password')
      end
    end

    context 'when user creation is unsuccessful' do
      before { allow(helper).to receive(:discord_user_create).and_return(false) }

      it 'sends an error message' do
        expect(helper).to receive(:send_message).with('User not created')
        helper.create_user_action('user@example.com', 'password')
      end
    end
  end

  describe '#register_action' do
    let(:user) { double('user') }
    before { allow(helper).to receive(:message).and_return('user@example.com:password') }
    before { allow(helper).to receive(:find_user).and_return(user) }

    context 'when user does not exist' do
      before { allow(user).to receive(:nil?).and_return(true) }

      it 'calls #create_user_action' do
        expect(helper).to receive(:create_user_action).with('user@example.com', 'password')
        helper.register_action
      end
    end

    context 'when user already exists' do
      before { allow(user).to receive(:nil?).and_return(false) }

      it 'sends an error message' do
        expect(helper).to receive(:send_message).with('User already exists')
        helper.register_action
      end
    end
  end
end