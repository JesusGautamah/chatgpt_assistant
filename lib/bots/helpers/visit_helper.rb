# frozen_string_literal: true

module ChatgptAssistant
  # Helper for visit
  module VisitHelper
    def telegram_visited?(chat_id)
      return unless msg

      visitor = Visitor.find_by(telegram_id: chat_id, name: msg.from.first_name)
      if visitor.nil?
        Visitor.create(telegram_id: chat_id, name: msg.from.first_name)
      else
        visitor
      end
    end
  end
end
