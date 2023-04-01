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
      init_log
      @response = request(message)
      @json = JSON.parse(response.body)
      logger.log("RESPONSE FROM OPENAI API: OK")

      return error_log if response.status != 200

      text = json["choices"][0]["message"]["content"]

      Message.create(content: text, role: "assistant", chat_id: chat_id)
      logger.log("MESSAGE SAVED IN DATABASE")
      text
    end

    private

    attr_reader :openai_api_key, :response, :message, :logger
    attr_accessor :chat_id, :json

    def init_log
      logger.log("REQUESTING OPENAI API COMPLETION")
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
      messages = Message.where(chat_id: chat_id).order(id: :asc).last(10)
      if messages.empty?
        ids = ["unknown"]
        messages = [{ role: "user", content: message }]
      else
        ids = messages.map(&:id)
        messages = messages.map { |mess| { role: mess.role, content: mess.content } }
      end
      logger.log("MESSAGES LOADED IN CONTEXT: #{messages.count}")
      messages.each_with_index do |mess, index|
        logger.log("MESSAGE ROLE: #{mess[:role]}, ID: #{ids[index]}")
      end
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
