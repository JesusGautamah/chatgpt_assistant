# frozen_string_literal: true

module ChatgptAssistant
  # Helper for authentication
  module AuthenticationHelper
    def valid_password?(password, hash, salt)
      BCrypt::Engine.hash_secret(password, salt) == hash
    end
  end
end
