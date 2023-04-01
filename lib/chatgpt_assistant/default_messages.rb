# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for storing the default messages
  class DefaultMessages
    def initialize(language = "en")
      @language = language
      load_message_context
    end

    attr_reader :language, :commom_messages, :success_messages, :error_messages, :help_messages

    def load_message_context
      @commom_messages = send("commom_messages_#{language}")
      @success_messages = send("success_messages_#{language}")
      @error_messages = send("error_messages_#{language}")
      @help_messages = send("help_messages_#{language}")
    end

    private

    def commom_messages_pt
      {
        start: "Olá, eu sou o Chatgpt Assistant, um chatbot que usa a API da OpenAI para responder suas perguntas no Telegram e Discord.",
        stop: "Até mais!",
        start_helper: "Primeiro, é necessário cadastrar seu usuário no banco de dados.
                       \nPara isso, mande ume mensagem com seu email e senha de acesso de 4 digitos.
                       \nExemplo: register/user@email.com:1234",
        start_sec_helper: "Caso você já tenha um usuário cadastrado, basta fazer login.
                           \nExemplo: login/user@email.com:3214",
        register: "Para se registrar no sistema, digite register/email:senha (a senha deve ser um numero de 4 digitos ex: 1234).
                   \nExemplo de Registro: register/user@email.com:3214",
        login: "Para fazer login no sistema, digite login/email:senha (a senha deve ser um numero de 4 digitos ex: 1234).
                \nExemplo de Login: login/user@mail.com:2134",
        chat_list: "Aqui estão os chats que você criou:"
      }
    end

    def success_messages_pt
      {
        user_created: "Usuário criado com sucesso!",
        chat_created: "Chat criado com sucesso!",
        chat_selected: "Chat selecionado com sucesso!",
        user_logged_in: "Login realizado com sucesso!",
        voice_channel_connected: "O bot entrou no canal de voz com sucesso!"
      }
    end

    def error_messages_pt
      {
        nil: "Não entendi o que você disse. Tente novamente",
        email: "O email que você digitou não é válido. Tente novamente",
        password: "A senha que você digitou não é válida. Tente novamente",
        user: "O usuário que você digitou não existe. Tente novamente",
        user_creation: "Erro ao criar usuário. Tente novamente",
        chat_creation: "Erro ao criar chat. Tente novamente",
        no_messages_founded: "Nenhuma mensagem encontrada",
        no_chat_selected: "Nenhum chat selecionado",
        chat_not_found: "Chat não encontrado",
        no_chats_founded: "Nenhum chat encontrado",
        user_not_logged_in: "Usuário não logado",
        user_not_found: "Usuário não encontrado",
        something_went_wrong: "Algo deu errado. Tente novamente mais tarde.",
        message_history_too_long: "O histórico mensagem é muito longo.",
        text_length: "O texto de resposta é muito longo. Tente diminuir a quantidade de respostas na mesma mensagem.",
        user_not_in_voice_channel: "Você não está em um canal de voz.",
        invalid_command: "Comando inválido. Tente novamente."
      }
    end

    def help_messages_pt
      ["Para começar a conversar comigo, digite /start",
       "Para parar de conversar comigo, digite /stop",
       "Para se registrar no sistema, digite register/email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
       "Para fazer login no sistema, digite login/email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
       "Para criar um novo chat, digite new_chat/nome do chat",
       "Para selecionar um chat, digite sl_chat/nome do chat",
       "Para listar os chats que você criou, digite /list",
       "Para ver esta mensagem novamente, digite /help"]
    end

    def commom_messages_en
      {
        start: "Hello, I'm the Chatgpt Assistant, a chatbot that uses the OpenAI API to answer your questions on Telegram and Discord.",
        stop: "See you later!",
        start_helper: "First, you need to register your user in the database.
                       \nTo do this, send a message with your email and password of 4 digits access.
                       \nExample: register/user@mail.com:3421",
        start_sec_helper: "If you already have a registered user, just log in.
                           \nExample: login/user@mail.com:5423",
        register: "To register in the system, type register/email:password (the password must be a 4 digit number ex: 1234).
                   \nExample of Registration: register/user@mail.com:3241",
        login: "To log in to the system, type login/email:password (the password must be a 4 digit number ex: 1234).
                \nExample of Login: login/user@mail.com:2134",
        chat_list: "Here are the chats you created:"
      }
    end

    def success_messages_en
      {
        user_created: "User created successfully!",
        chat_created: "Chat created successfully!",
        chat_selected: "Chat selected successfully!",
        user_logged_in: "Login successfully!"
      }
    end

    def error_messages_en
      {
        nil: "I didn't understand what you said. Try again",
        email: "The email you typed is not valid. Try again",
        password: "The password you typed is not valid. Try again",
        user: "The user you typed does not exist. Try again",
        user_creation: "Error creating user. Try again",
        chat_creation: "Error creating chat. Try again",
        no_messages_founded: "No messages found",
        no_chat_selected: "No chat selected",
        no_chats_founded: "No chats found",
        chat_not_found: "Chat not found",
        user_not_logged_in: "User not logged in",
        user_not_found: "User not found",
        something_went_wrong: "Something went wrong. Try again later.",
        message_history_too_long: "The message history is too long.",
        text_length: "The response text is too long. Try to reduce the number of answers in the same message.",
        user_not_in_voice_channel: "You are not in a voice channel.",
        invalid_command: "Invalid command. Try again."
      }
    end

    def help_messages_en
      ["To start talking to me, type /start",
       "To stop talking to me, type /stop",
       "To register in the system, type register/email:password (the password must be a 4 digit number ex: 1234)",
       "To log in to the system, type login/email:password (the password must be a 4 digit number ex: 1234)",
       "To create a new chat, type new_chat/chat name",
       "To select a chat, type sl_chat/chat name",
       "To list the chats you created, type /list",
       "To see this message again, type /help"]
    end
  end
end
