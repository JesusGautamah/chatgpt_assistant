# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for storing the default messages
  class DefaultMessages
    def initialize
      @language = ENV['LANGUAGE'] || 'en'
      load_message_context
    end

    attr_reader :language, :start_messages, :end_messages, :help_messages, :error_messages, :welcome_message, :chat_creation_success_message, :chat_creation_failed_message, :not_logged_in_messages

    def load_message_context
      @start_messages = send("start_messages_#{language}")
      @end_messages = send("end_messages_#{language}")
      @help_messages = send("help_messages_#{language}")
      @error_messages = send("error_messages_#{language}")
      @welcome_message = send("welcome_message_#{language}")
      @chat_creation_success_message = send("chat_creation_success_message_#{language}")
      @chat_creation_failed_message = send("chat_creation_failed_message_#{language}")
      @not_logged_in_messages = send("not_logged_in_messages_#{language}")
    end

    def start_messages_pt
      ["Primeiro, é necessário cadastrar seu usuário no banco de dados. Para isso, mande ume mensgem com seu email e senha de acesso de 4 digitos. Exemplo:",
       "register/email@dousuario.com:1234"]
    end

    def end_messages_pt
      ["Até mais!",
       "Se quiser conversar comigo novamente, basta fazer login"]
    end

    def help_messages_pt
      ["Para começar a conversar comigo, digite /start",
       "Para parar de conversar comigo, digite /stop",
       "Para se registrar no sistema, digite register/email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
       "Para fazer login no sistema, digite login/email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
       "Para criar um novo chat, digite novo_chat/nome do chat",
       "Para selecionar um chat, digite sl_chat/nome do chat",
       "Para listar os chats que você criou, digite /listar",
       "Para ver esta mensagem novamente, digite /ajuda"]
    end

    def error_messages_pt
      {
        nil: "Não entendi o que você disse. Tente novamente",
        email: "O email que você digitou não é válido. Tente novamente",
        password: "A senha que você digitou não é válida. Tente novamente",
        user: "O usuário que você digitou não existe. Tente novamente"
      }
    end

    def welcome_message_pt
      "Olá, eu sou o Focus Bot, um chatbot que usa a API da OpenAI para responder suas perguntas no Telegram."
    end

    def chat_creation_success_message_pt
      "Chat criado com sucesso!"
    end

    def chat_creation_failed_message_pt
      "Erro ao criar chat!"
    end

    def not_logged_in_messages_pt
      ["Você não está logado no sistema. Para começar mande seu email e senha de acesso de 4 digitos. Exemplo de Login:", "login/user@email.com:1234",
       "Para se registrar no sistema, digite register/email:senha (a senha deve ser um numero de 4 digitos ex: 1234). Exemplo de Registro:", "register/email@user.com:1234"]
    end

    def start_messages_en
      ["First, you need to register your user in the database. To do this, send a message with your email and password of 4 digits access. Example:",
       "register/user@mail.com:1234"]
    end

    def end_messages_en
      ["See you later!",
       "If you want to talk to me again, just log in"]
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

    def error_messages_en
      { 
        nil: "I didn't understand what you said. Try again",
        email: "The email you typed is not valid. Try again",
        password: "The password you typed is not valid. Try again",
        user: "The user you typed does not exist. Try again"
      }
    end

    def welcome_message_en
      "Hi, I'm the Focus Bot, a chatbot that uses the OpenAI API to answer your questions on Telegram."
    end

    def chat_creation_success_message_en
      "Chat created successfully!"
    end

    def chat_creation_failed_message_en
      "Error creating chat!"
    end

    def not_logged_in_messages_en
      ["You are not logged in to the system. To start send your email and password of 4 digits access. Login Example:", "
        login/user@mail.com:1234",
        "To register in the system, type register/email:password (the password must be a 4 digit number ex: 1234). Registration Example:", "
        register/user@mail.com:1234"]
    end
  end
end
