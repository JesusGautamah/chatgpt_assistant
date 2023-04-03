# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to contain the shared variables between the bot classes
  class ApplicationBot
    def initialize(config)
      @config = config
      default_msg = DefaultMessages.new(@config.language)
      @openai_api_key = @config.openai_api_key
      @telegram_token = @config.telegram_token
      @discord_token = @config.discord_token
      @discord_client_id = @config.discord_client_id
      @discord_prefix = @config.discord_prefix
      @database = @config.db_connection
      @mode = @config.mode
      @commom_messages = default_msg.commom_messages
      @error_messages = default_msg.error_messages
      @success_messages = default_msg.success_messages
      @help_messages = default_msg.help_messages
    end

    def chatter
      @chatter ||= Chatter.new(openai_api_key)
    end

    def audio_recognition
      @audio_recognition ||= AudioRecognition.new(openai_api_key)
    end

    def audio_synthesis
      @audio_synthesis ||= AudioSynthesis.new(config)
    end

    def transcribed_text
      audio_recognition.transcribe_audio(audio_url)
    end

    def find_useremail(email)
      User.find_by(email: email)
    end

    def find_userdiscord(discord_id)
      User.find_by(discord_id: discord_id)
    end

    def find_usertelegram(telegram_id)
      User.find_by(telegram_id: telegram_id)
    end

    def valid_password?(user, password)
      return false if password.nil?

      salt = user.password_salt
      password_hash = user.password_hash

      BCrypt::Engine.hash_secret(password, salt) == password_hash
    end

    def auth_userdiscord(email, password, discord_id)
      user = find_useremail(email)
      return "user not found" unless user
      return "wrong password" if password.nil?

      valid_password?(user, password) ? user_disc_access(discord_id, user.email) : "wrong password"
    end

    def user_disc_access(discord_id, user_email)
      last_access = find_userdiscord(discord_id)
      new_access = find_useremail(user_email)
      last_acess.update(discord_id: nil) if last_access && (last_access != new_access)
      new_access.update(discord_id: discord_id)
      new_access
    end

    def discord_user_create(discord_id, email, password, name)
      user = User.new(discord_id: discord_id, email: email, password_hash: password, name: name)
      last_access = find_userdiscord(discord_id)
      last_access&.update(discord_id: nil)
      user.save
    end

    def auth_usertelegram(email, password, telegram_id)
      user = find_useremail(email)
      return "user not found" unless user
      return "wrong password" if password.nil?

      valid_password?(user, password) ? user_tele_access(telegram_id, user.email) : "wrong password"
    end

    def user_tele_access(telegram_id, user_email)
      last_access = find_usertelegram(telegram_id)
      new_access = find_useremail(user_email)
      last_acess.update(telegram_id: nil) if last_access && (last_access != new_access)
      new_access.update(telegram_id: telegram_id)
      new_access
    end

    def telegram_user_create(telegram_id, email, password, name)
      user = User.new(telegram_id: telegram_id, email: email, password_hash: password, name: name)
      last_access = find_usertelegram(telegram_id)
      last_access&.update(telegram_id: nil)
      user.save
    end

    def delete_all_voice_files
      Dir.glob("voice/*").each do |file|
        next if [".keep", "voice/.keep"].include?(file)

        File.delete(file)
      end
    end

    attr_reader :openai_api_key, :telegram_token, :database, :default_msg,
                :mode, :config, :discord_token, :discord_client_id,
                :discord_prefix, :commom_messages, :error_messages, :success_messages,
                :help_messages
  end
end
