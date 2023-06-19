# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to background the register service
  class RegisterService
    def initialize(email, password, name, chat_id)
      @name = name
      @email = email
      @password = password
      @chat_id = chat_id
      @config = Config.new
      @config.db_connection
    end

    def call
      return if user_already_exists?

      @user = User.new(email: @email, password: @password, telegram_id: @chat_id, name: @name)
      @user.save ? success_message : error_message
    rescue UserAlreadyExistsError, WrongEmailError, WrongPasswordError => e
      telegram_async.send_message(e.message, @chat_id)
    rescue StandardError => e
      telegram_async.send_message(e.message, @chat_id) if ENV["ENV_TYPE"] == "development"
      backtrace = e.backtrace.join(" \n ")
      telegram_async.send_message(backtrace, @chat_id) if ENV["ENV_TYPE"] == "development"
    end

    private

      def telegram_async
        TelegramBot.new(@config)
      end

      def success_message
        confirmation_token = @user.encrypt_token
        telegram_async.send_message("Registration successful! Check your email for confirmation.", @chat_id)
        AccountMailer.register_email(@user, confirmation_token).deliver_now
      end

      def error_message
        raise WrongEmailError if @user.errors[:email].any?
        raise WrongPasswordError if @user.errors[:password].any?
      end

      def user_already_exists?
        raise UserAlreadyExistsError if User.find_by(email: @email)
      end
  end
end
