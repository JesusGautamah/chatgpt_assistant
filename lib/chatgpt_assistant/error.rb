# frozen_string_literal: true

module ChatgptAssistant
  # Load Error
  module LoadError
    def load_error_context
      language = ENV.fetch("LANGUAGE", "en")
      discord_prefix = ENV.fetch("DISCORD_PREFIX", "!")
      DefaultMessages.new(language, discord_prefix).error_messages
    end
  end

  # Nil Error
  class NilError < StandardError
    def initialize(message = load_error_context[:nil])
      super(message)
    end

    include LoadError
  end

  # Wrong Email Error
  class WrongEmailError < StandardError
    def initialize(message = load_error_context[:wrong_email])
      super(message)
    end

    include LoadError
  end

  # Wrong Password Error
  class WrongPasswordError < StandardError
    def initialize(message = load_error_context[:wrong_password])
      super(message)
    end

    include LoadError
  end

  # User Already Exists Error
  class UserAlreadyExistsError < StandardError
    def initialize(message = load_error_context[:user_already_exists])
      super(message)
    end

    include LoadError
  end

  # Chat Already Exists Error
  class ChatAlreadyExistsError < StandardError
    def initialize(message = load_error_context[:chat_already_exists])
      super(message)
    end

    include LoadError
  end

  # Sign Up Error
  class SignUpError < StandardError
    def initialize(message = load_error_context[:sign_up_error])
      super(message)
    end

    include LoadError
  end

  # Chat Not Created Error
  class ChatNotCreatedError < StandardError
    def initialize(message = load_error_context[:chat_not_created_error])
      super(message)
    end

    include LoadError
  end

  # Message Not Created Error
  class MessageNotCreatedError < StandardError
    def initialize(message = load_error_context[:message_not_created_error])
      super(message)
    end

    include LoadError
  end

  # No Chat Selected Error
  class NoChatSelectedError < StandardError
    def initialize(message = load_error_context[:no_chat_selected])
      super(message)
    end

    include LoadError
  end

  # No Messages Founded Error
  class NoMessagesFoundedError < StandardError
    def initialize(message = load_error_context[:no_messages_founded])
      super(message)
    end

    include LoadError
  end

  # No Chats Founded Error
  class NoChatsFoundedError < StandardError
    def initialize(message = load_error_context[:no_chats_founded])
      super(message)
    end

    include LoadError
  end

  # Chat Not Found Error
  class ChatNotFoundError < StandardError
    def initialize(message = load_error_context[:chat_not_found])
      super(message)
    end

    include LoadError
  end

  # User Not Found Error
  class UserNotFoundError < StandardError
    def initialize(message = load_error_context[:user_not_found])
      super(message)
    end

    include LoadError
  end

  # User Not Registered Error
  class UserNotRegisteredError < StandardError
    def initialize(message = load_error_context[:user_not_registered])
      super(message)
    end

    include LoadError
  end

  # User Not Logged In Error
  class UserNotLoggedInError < StandardError
    def initialize(message = load_error_context[:user_not_logged_in])
      super(message)
    end

    include LoadError
  end

  # User Not In Voice Channel Error
  class UserNotInVoiceChannelError < StandardError
    def initialize(message = load_error_context[:user_not_in_voice_channel])
      super(message)
    end

    include LoadError
  end

  # Bot Not In Voice Channel Error
  class BotNotInVoiceChannelError < StandardError
    def initialize(message = load_error_context[:bot_not_in_voice_channel])
      super(message)
    end

    include LoadError
  end

  # Message Not Found Error
  class MessageHistoryTooLongError < StandardError
    def initialize(message = load_error_context[:message_history_too_long])
      super(message)
    end

    include LoadError
  end

  # Text Length Too Long Error
  class TextLengthTooLongError < StandardError
    def initialize(message = load_error_context[:text_length_too_long])
      super(message)
    end

    include LoadError
  end

  # Invalid Command Error
  class InvalidCommandError < StandardError
    def initialize(message = load_error_context[:invalid_command])
      super(message)
    end

    include LoadError
  end

  # Something Went Wrong Error
  class SomethingWentWrongError < StandardError
    def initialize(message = load_error_context[:something_went_wrong])
      super(message)
    end

    include LoadError
  end
end
