# frozen_string_literal: true

# Gem module
module ChatgptAssistant
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", nil),
    port: ENV.fetch("SMTP_PORT", nil),
    domain: ENV.fetch("SMTP_DOMAIN", nil),
    user_name: ENV.fetch("SMTP_USER_NAME", nil),
    password: ENV.fetch("SMTP_PASSWORD", nil),
    authentication: ENV.fetch("SMTP_AUTHENTICATION", nil),
    enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", nil) == "true"
  }

  # This class is responsible for the application mailer
  class ApplicationMailer < ActionMailer::Base
    default from: "support@chat.outerspacecoding.com"
  end
end
