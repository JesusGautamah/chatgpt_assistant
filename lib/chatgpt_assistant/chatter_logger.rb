# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for logging the messages
  class ChatterLogger
    def initialize
      @file_name = "logs/telegram_chatgpt.log"
      @log_file = File.open("logs/telegram_chatgpt.log", "a")
    end

    attr_reader :log_file

    def log(message)
      log_file.puts(message)
      system "echo '#{message}'"
    end
  end
end
