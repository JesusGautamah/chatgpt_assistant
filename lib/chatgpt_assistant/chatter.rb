# frozen_string_literal: true

require "faraday"
require_relative "models"

module ChatgptAssistant
  # This is the Chat Ai class
  class Chatter
    def initialize(openai_api_key)
      @openai_api_key = openai_api_key
    end

    def chat(message, chat_id)
      @chat_id = chat_id
      @message = message
      @response = request(message)
      @json = JSON.parse(response.body)

      return error_log if response.status != 200

      text = json["choices"][0]["message"]["content"]

      Message.create(content: text, role: "assistant", chat_id: chat_id)
      text
    end

    private

    attr_reader :openai_api_key, :response, :message
    attr_accessor :chat_id, :json

    def error_log
      "Algo deu errado, tente novamente mais tarde."
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
      messages = Message.where(chat_id: chat_id).order(id: :asc).last(10)
      messages = messages.empty? ? [{ role: "user", content: message }] : messages.map { |mess| { role: mess.role, content: mess.content } }
      {
        model: "gpt-3.5-turbo",
        messages: messages
      }.to_json
    end

    def request(message)
      connection.post("v1/chat/completions", request_params(message), header)
    end
  end
end
