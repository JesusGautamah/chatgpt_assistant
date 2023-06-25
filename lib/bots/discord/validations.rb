# frozen_string_literal: true

module Bots
  module Discord
    module Validations
      def discord_next_action?
        return true if evnt.channel.type != 1 && evnt.channel.name != "ai-spaces"

        %w[login register start help new_chat sl_chat ask
           list hist connect disconnect speak].each do |action|
          return true if evnt.message.content.include?("#{discord_prefix}#{action}")
        end
        false
      end

      def discord_voice_bot_disconnected?
        user && evnt.user.voice_channel && !evnt.voice && !chat.nil?
      end

      def discord_voice_bot_connected?
        user && evnt.user.voice_channel && evnt.voice && !chat.nil?
      end

      def visitor_user?
        visitor&.dis_user.nil?
      end

      def valid_for_list_action?
        not_logged_in_message if user.nil?
        not_verified_message unless user.active?
        chat_not_found_message if user.chats.count.zero? && user.active?
        !user.nil? && user.active? && user.chats.count.positive?
      end
    end
  end
end
