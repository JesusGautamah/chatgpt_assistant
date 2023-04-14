# frozen_string_literal: true

module ChatgptAssistant
  module LoadError
    def load_error_context
      language = ENV.fetch("LANGUAGE", "en")
      discord_prefix = ENV.fetch("DISCORD_PREFIX", "!")
      DefaultMessages.new(language, discord_prefix).error_messages
    end
  end

  class NilError < StandardError
    def initialize(message = load_error_context[:nil])
      super(message)
    end

    include LoadError
  end

  class WrongEmailError < StandardError
    def initialize(message = load_error_context[:wrong_email])
      super(message)
    end

    include LoadError
  end

  class WrongPasswordError < StandardError
    def initialize(message = load_error_context[:wrong_password])
      super(message)
    end

    include LoadError
  end

  class UserAlreadyExistsError < StandardError
    def initialize(message = load_error_context[:user_already_exists])
      super(message)
    end

    include LoadError
  end

  class ChatAlreadyExistsError < StandardError
    def initialize(message = load_error_context[:chat_already_exists])
      super(message)
    end

    include LoadError
  end

  class SignUpError < StandardError
    def initialize(message = load_error_context[:sign_up_error])
      super(message)
    end

    include LoadError
  end

  class ChatNotCreatedError < StandardError
    def initialize(message = load_error_context[:chat_not_created_error])
      super(message)
    end

    include LoadError
  end

  class MessageNotCreatedError < StandardError
    def initialize(message = load_error_context[:message_not_created_error])
      super(message)
    end

    include LoadError
  end

  class NoChatSelectedError < StandardError
    def initialize(message = load_error_context[:no_chat_selected])
      super(message)
    end

    include LoadError
  end

  class NoMessagesFoundedError < StandardError
    def initialize(message = load_error_context[:no_messages_founded])
      super(message)
    end

    include LoadError
  end

  class NoChatsFoundedError < StandardError
    def initialize(message = load_error_context[:no_chats_founded])
      super(message)
    end

    include LoadError
  end

  class ChatNotFoundError < StandardError
    def initialize(message = load_error_context[:chat_not_found])
      super(message)
    end

    include LoadError
  end

  class UserNotFoundError < StandardError
    def initialize(message = load_error_context[:user_not_found])
      super(message)
    end

    include LoadError
  end

  class UserNotRegisteredError < StandardError
    def initialize(message = load_error_context[:user_not_registered])
      super(message)
    end

    include LoadError
  end

  class UserNotLoggedInError < StandardError
    def initialize(message = load_error_context[:user_not_logged_in])
      super(message)
    end

    include LoadError
  end

  class UserNotInVoiceChannelError < StandardError
    def initialize(message = load_error_context[:user_not_in_voice_channel])
      super(message)
    end

    include LoadError
  end

  class BotNotInVoiceChannelError < StandardError
    def initialize(message = load_error_context[:bot_not_in_voice_channel])
      super(message)
    end

    include LoadError
  end

  class MessageHistoryTooLongError < StandardError
    def initialize(message = load_error_context[:message_history_too_long])
      super(message)
    end

    include LoadError
  end

  class TextLengthTooLongError < StandardError
    def initialize(message = load_error_context[:text_length_too_long])
      super(message)
    end

    include LoadError
  end

  class InvalidCommandError < StandardError
    def initialize(message = load_error_context[:invalid_command])
      super(message)
    end

    include LoadError
  end

  class SomethingWentWrongError < StandardError
    def initialize(message = load_error_context[:something_went_wrong])
      super(message)
    end

    include LoadError
  end
end
