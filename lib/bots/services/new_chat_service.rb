#  frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible to background the new chat service
  class NewChatService
    def initialize(chat_title, user_id, chat_id, config)
      @chat_title = chat_title
      @user_id = user_id
      @chat_id = chat_id
      @config = config
    end

    def telegram_async
      TelegramBot.new(@config)
    end

    def call
      raise ChatAlreadyExistsError if Chat.find_by(title: @chat_title)
      raise NilError if @chat_title.nil?
      raise NilError if @user_id.nil?
      raise NilError if @chat_id.nil?

      chat = Chat.new(title: @chat_title, user_id: @user_id)
      if chat.save
        telegram_async.send_message("Chat created succesfully", @chat_id)
      else
        raise ChatAlreadyExistsError if Chat.find_by(title: @chat_title)
        raise NilError if chat.errors[:title].any?
      end
    rescue ChatAlreadyExistsError, NilError => e
      telegram_async.send_message(e.message, @chat_id)
    end
  end
end
