# frozen_string_literal: true

module ChatgptAssistant
  # Helper for files
  module FileHelper
    def delete_file(file)
      File.delete file
    end
  end
end
