# frozen_string_literal: true

require "faraday"
require_relative "models"

module ChatgptAssistant
  # This is the Chat Ai class
  class Chatter
    def initialize(openai_api_key)
      @openai_api_key = openai_api_key
    end

    def chat(message, chat_id, error_message)
      @error_message = error_message
      @chat_id = chat_id
      @message = message
      @response = request(message)
      @json = JSON.parse(response.body)

      return no_response_error if json["choices"] && json["choices"].empty?
      return bot_offline_error if response.status != 200

      text = json["choices"][0]["message"]["content"]

      Message.create(content: text, role: "assistant", chat_id: chat_id)
      text
    rescue StandardError => e
      Error.create(message: e.message, backtrace: e.backtrace)
      error_message
    end

    private

      attr_reader :openai_api_key, :response, :message
      attr_accessor :chat_id, :json, :error_message

      def no_response_error
        "I'm sorry, I didn't understand you. Please, try again."
      end

      def bot_offline_error
        "I'm sorry, I'm offline. Please, try again later."
      end

      def header
        {
          "Content-Type": "application/json",
          Authorization: "Bearer #{openai_api_key}"
        }
      end

      def connection
        Faraday.new(url: "https://api.openai.com/") do |faraday|
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end
      end

      def request_params(message)
        messages_from_chat = Message.where(chat_id: chat_id)
        messages = messages_from_chat.order(id: :asc).last(10)
        messages = if messages.empty?
                     [{ role: "user", content: message }]
                   else
                     messages.map do |mess|
                       { role: mess.role,
                         content: mess.content }
                     end
                   end

        first_message = messages_from_chat.order(id: :asc).first
        system_message = first_message if first_message&.role == "system"
        if system_message && Message.where(chat_id: chat_id).count > 10
          messages.unshift({ role: system_message.role,
                             content: system_message.content })
        end
        {
          model: "gpt-3.5-turbo",
          messages: messages,
          max_tokens: 1000,
          temperature: 0.1
        }.to_json
      end

      def request(message)
        connection.post("v1/chat/completions", request_params(message), header)
      end
  end
end
