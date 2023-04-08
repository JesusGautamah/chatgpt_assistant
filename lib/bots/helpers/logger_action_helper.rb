# frozen_string_literal: true

module ChatgptAssistant
  # Helper for logger action
  module LoggerActionHelper
    def register_visitor_action(action, visitor_id)
      VisitorAction.create(visitor_id: visitor_id, action: action, description: msg.text)
    end

    def register_user_action(action, user_id)
      UserAction.create(user_id: user_id, action: action, description: msg.text)
    end
  end
end
