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

    def actors
      @actors ||= AwesomeChatgptActors::CastControl.actors
    end

    def actor
      @actor_name = actors[@actor_mode.to_i - 1] if @actor_mode
      @actor = AwesomeChatgptActors::Actor.new(role: @actor_name, language: @config.language) if @actor_name
    end

    def chat
      @chat = Chat.new(title: @chat_title, user_id: @user_id, status: 0, actor: @actor_name, prompt: @actor.prompt) if !@actor.nil? && @actor_name
      @chat = Chat.new(title: @chat_title, user_id: @user_id, status: 0) unless @actor_name
    end

    def parse_title
      return @chat_title.strip! unless @chat_title.include?("actor:")

      @actor_mode = @chat_title.split("actor:")[1].strip
      @chat_title = @chat_title.split("actor:")[0].strip
    end

    def call
      raise NilError if @chat_title.nil?
      raise NilError if @user_id.nil?
      raise NilError if @chat_id.nil?

      parse_title

      raise InvalidModeError unless (@actor_mode.to_i >= 1 && @actor_mode.to_i <= actors.size + 1) || @actor_mode.nil?
      raise InvalidChatTitleError if @chat_title.nil? || @chat_title.empty?
      raise ChatAlreadyExistsError if Chat.find_by(title: @chat_title)

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
