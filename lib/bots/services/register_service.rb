# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to background the register service
  class RegisterService
    def initialize(email, password, chat_id)
      @email = email
      @password = password
      @chat_id = chat_id
      @config = Config.new
      @config.db_connection
    end

    def telegram_async
      TelegramBot.new(@config)
    end

    def call
      user = User.find_by(email: @email)
      if user
        telegram_async.send_message("User already exists", @chat_id)
      else
        user = User.new(email: @email, password: @password, telegram_id: @chat_id)
        if user.save
          telegram_async.send_message("User created", @chat_id)
        else
          raise UserAlreadyExistsError if User.find_by(email: @email)
          raise WrongEmailError if user.errors[:email].any?
          raise WrongPasswordError if user.errors[:password].any?
        end
      end
    rescue UserAlreadyExistsError, WrongEmailError, WrongPasswordError => e
      telegram_async.send_message(e.message, @chat_id)
    end
  end
end
