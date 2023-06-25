# frozen_string_literal: true

module ChatgptAssistant
  # Helper for messenger
  module MessengerHelper
    def parse_message(message, max_length)
      if message.length > max_length
        array = message.scan(/.{1,#{max_length}}/) if max_length.positive?
        array = ["Something went wrong! Try again later"] if max_length <= 0
      else
        array = [message]
      end
      array
    end
  end
end
