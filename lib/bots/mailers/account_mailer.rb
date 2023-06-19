# frozen_string_literal: true

require_relative "application_mailer"

module ChatgptAssistant
  # This class is responsible for the register mailer
  class AccountMailer < ApplicationMailer
    def register_email(user, token)
      @user = user
      @token = token
      mail(to: user.email, subject: "Welcome to ChatGPT Assistant",
           content_type: "text/html",
           body: register_html)
    end

    private

      attr_reader :user, :token

      def register_html
        "<h1>Welcome to ChatGPT Assistant</h1> \n
        <p>Hi #{user.name}</p> \n
        <p>You are now registered to ChatGPT Assistant</p> \n
        <p>You can now start using the bot</p> \n
        <p>To start using the bot, copy and paste the following link in TELEGRAM bot:</p> \n
        <p>confirm/* #{user.name}:#{token}</p> \n
        "
      end
  end
end
