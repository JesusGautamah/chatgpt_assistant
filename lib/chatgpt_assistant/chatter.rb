# frozen_string_literal: true

require "faraday"
require_relative "models"
require_relative "chatter_logger"

module ChatgptAssistant
  # This is the Chat Ai class
  class Chatter
    def initialize(openai_api_key)
      @openai_api_key = openai_api_key
      @logger = ChatterLogger.new
    end

    def chat(message, chat_id)
      @chat_id = chat_id
      @message = message
      @response = request(message)
      @json = JSON.parse(response.body)
      init_log

      return error_log if response.status != 200

      text = json["choices"][0]["message"]["content"].gsub("```", "`").to_s

      Message.create(content: text, role: "assistant", chat_id: chat_id)
      text
    end

    private

    attr_reader :openai_api_key, :response, :message, :logger
    attr_accessor :chat_id, :json

    def init_log
      logger.log("REQUESTING OPENAI API COMPLETION")
      logger.log("Message: #{message}")
    end

    def error_log
      logger.log("RESPONSE FROM OPENAI API ERROR")
      logger.log("RESPONSE STATUS: #{response.status}")
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
      messages = Message.where(chat_id: chat_id).order(:created_at).limit(15)
      if messages.empty?
        messages = [{ role: "user", content: message }]
      else
        messages = messages.map { |mess| { role: mess.role, content: mess.content } }
        messages += [{ role: "user", content: message }]
      end
      logger.log("Messages in this conversation: #{messages.count}")
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
