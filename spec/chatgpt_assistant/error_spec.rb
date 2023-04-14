RSpec.describe ChatgptAssistant::NilError do
  let(:error_message) { ChatgptAssistant::DefaultMessages.new.error_messages[:nil] }

  it 'raises a NilError with the default error message' do
    expect { raise described_class }.to raise_error(described_class, error_message)
  end

  it 'raises a NilError with a custom error message' do
    custom_message = 'Custom error message'
    expect { raise described_class, custom_message }.to raise_error(described_class, custom_message)
  end
end

RSpec.describe ChatgptAssistant::WrongEmailError do
  let(:error_message) { ChatgptAssistant::DefaultMessages.new.error_messages[:wrong_email] }

  it 'raises a WrongEmailError with the default error message' do
    expect { raise described_class }.to raise_error(described_class, error_message)
  end

  it 'raises a WrongEmailError with a custom error message' do
    custom_message = 'Custom error message'
    expect { raise described_class, custom_message }.to raise_error(described_class, custom_message)
  end
end

RSpec.describe ChatgptAssistant::WrongPasswordError do
  let(:error_message) { ChatgptAssistant::DefaultMessages.new.error_messages[:wrong_password] }

  it 'raises a WrongPasswordError with the default error message' do
    expect { raise described_class }.to raise_error(described_class, error_message)
  end

  it 'raises a WrongPasswordError with a custom error message' do
    custom_message = 'Custom error message'
    expect { raise described_class, custom_message }.to raise_error(described_class, custom_message)
  end
end

RSpec.describe ChatgptAssistant::UserAlreadyExistsError do
  let(:error_message) { ChatgptAssistant::DefaultMessages.new.error_messages[:user_already_exists] }

  it 'raises a UserAlreadyExistsError with the default error message' do
    expect { raise described_class }.to raise_error(described_class, error_message)
  end

  it 'raises a UserAlreadyExistsError with a custom error message' do
    custom_message = 'Custom error message'
    expect { raise described_class, custom_message }.to raise_error(described_class, custom_message)
  end
end

RSpec.describe ChatgptAssistant::ChatAlreadyExistsError do
  let(:error_message) { ChatgptAssistant::DefaultMessages.new.error_messages[:chat_already_exists] }

  it 'raises a ChatAlreadyExistsError with the default error message' do
    expect { raise described_class }.to raise_error(described_class, error_message)
  end

  it 'raises a ChatAlreadyExistsError with a custom error message' do
    custom_message = 'Custom error message'
    expect { raise described_class, custom_message }.to raise_error(described_class, custom_message)
  end
end

RSpec.describe ChatgptAssistant::SignUpError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'Error creating user. Try again' }
    end

    context 'when message is passed' do
      let(:message) { 'Invalid email' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::ChatNotCreatedError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'Error creating chat. Try again' }
    end

    context 'when message is passed' do
      let(:message) { 'Error creating chat' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::MessageNotCreatedError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'Error creating message. Try again' }
    end

    context 'when message is passed' do
      let(:message) { 'Error creating message' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::NoChatSelectedError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'No chat selected' }
    end

    context 'when message is passed' do
      let(:message) { 'Please select a chat' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::NoMessagesFoundedError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'No messages found' }
    end

    context 'when message is passed' do
      let(:message) { 'No messages were found' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::NoChatsFoundedError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'No chats found' }
    end

    context 'when message is passed' do
      let(:message) { 'No chats were found' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::ChatNotFoundError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'Chat not found' }
    end

    context 'when message is passed' do
      let(:message) { 'The specified chat was not found' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::UserNotFoundError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq "The user you typed does not exist. Try again" }
    end

    context 'when message is passed' do
      let(:message) { 'The specified user was not found' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::UserNotRegisteredError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq "The user is not registered in the system" }
    end

    context 'when message is passed' do
      let(:message) { 'The specified user is not registered' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::UserNotLoggedInError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'User not logged in' }
    end

    context 'when message is passed' do
      let(:message) { 'The user is not currently logged in' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::UserNotInVoiceChannelError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq "You are not in a voice channel." }
    end

    context 'when message is passed' do
      let(:message) { 'The user is not in a voice channel' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::BotNotInVoiceChannelError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'The bot is not in a voice channel.' }
    end

    context 'when message is passed' do
      let(:message) { 'Bot is not connected to any voice channel' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::MessageHistoryTooLongError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq 'The message history is too long.' }
    end

    context 'when message is passed' do
      let(:message) { "Message history is too long." }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::TextLengthTooLongError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq "The response text is too long. Try to reduce the number of responses in the same message." }
    end

    context 'when message is passed' do
      let(:message) { "Text too long." }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::InvalidCommandError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq "Invalid command. Try again." }
    end

    context 'when message is passed' do
      let(:message) { 'The command entered is not valid' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end

RSpec.describe ChatgptAssistant::SomethingWentWrongError do
  let(:error) { described_class.new }

  describe '#message' do
    subject { error.message }

    context 'when message is not passed' do
      it { is_expected.to eq "Something went wrong. Try again later." }
    end

    context 'when message is passed' do
      let(:message) { 'An error occurred, please try again later' }
      let(:error) { described_class.new(message) }

      it { is_expected.to eq message }
    end
  end
end