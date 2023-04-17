# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for storing the default messages
  class DefaultMessages
    def initialize(language = "en", _discord_prefix = "!")
      @language = language
      load_message_context
    end

    attr_reader :language, :common_messages, :success_messages, :error_messages, :help_messages

    def load_message_context
      @common_messages = send("common_messages_#{language}")
      @success_messages = send("success_messages_#{language}")
      @error_messages = send("error_messages_#{language}")
      @help_messages = send("help_messages_#{language}")
    end

    private

      def common_messages_pt
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
          user_logged_out: "Logout realizado com sucesso!",
          voice_channel_connected: "O bot entrou no canal de voz com sucesso!"
        }
      end

      def error_messages_pt
        {
          nil: "Não entendi o que você disse. Tente novamente",
          wrong_email: "O email que você digitou não é válido. Tente novamente",
          wrong_password: "A senha que você digitou não é válida. Tente novamente",

          user_already_exists: "O usuário que você digitou já existe. Tente novamente",
          chat_already_exists: "Você já possui um chat com este titulo. Tente novamente",

          no_register_info: "Você não digitou o email e a senha. Tente novamente",
          sign_up_error: "Erro ao criar usuário. Tente novamente",
          chat_not_created_error: "Erro ao criar chat. Tente novamente",
          message_not_created_error: "Erro ao criar mensagem. Tente novamente",
          no_chat_selected: "Nenhum chat selecionado",

          no_messages_founded: "Nenhuma mensagem encontrada",
          no_chats_founded: "Nenhum chat encontrado",
          chat_not_found: "Chat não encontrado",
          user_not_found: "O usuário que você digitou não existe. Tente novamente",
          user_not_registered: "O usuário não está registrado no sistema",
          user_logged_in: "Usuário está logado no sistema, faça logout para continuar",
          user_not_logged_in: "Usuário não logado",

          user_not_in_voice_channel: "Você não está em um canal de voz.",
          bot_not_in_voice_channel: "O bot não está em um canal de voz.",

          message_history_too_long: "O histórico mensagem é muito longo.",
          text_length_too_long: "O texto de resposta é muito longo. Tente diminuir a quantidade de respostas na mesma mensagem.",

          invalid_command: "Comando inválido. Tente novamente.",
          something_went_wrong: "Algo deu errado. Tente novamente mais tarde."
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

      def help_message_discord_pt
        ["Para começar a conversar comigo, digite #{discord_prefix}start",
         "Para parar de conversar comigo, digite #{discord_prefix}stop",
         "Para se registrar no sistema, digite #{discord_prefix}register email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
         "Para fazer login no sistema, digite #{discord_prefix}login email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
         "Para criar um novo chat, digite #{discord_prefix}new_chat nome do chat",
         "Para selecionar um chat, digite #{discord_prefix}sl_chat nome do chat",
         "Para listar os chats que você criou, digite #{discord_prefix}list",
         "Para ver esta mensagem novamente, digite #{discord_prefix}help"]
      end

      def common_messages_en
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
          user_logged_in: "Login successfully!",
          user_logged_out: "Logout successfully!",
          voice_channel_connected: "The bot entered the voice channel successfully!"
        }
      end

      def error_messages_en
        {
          nil: "I don't understand what you said. Try again",
          wrong_email: "The email you typed is not valid. Try again",
          wrong_password: "The password you typed is not valid. Try again",

          user_already_exists: "The user you typed already exists. Try again",
          chat_already_exists: "You already have a chat with this title. Try again",

          no_register_info: "You did not type the email and password. Try again",
          sign_up_error: "Error creating user. Try again",
          chat_not_created_error: "Error creating chat. Try again",
          message_not_created_error: "Error creating message. Try again",
          no_chat_selected: "No chat selected",

          no_messages_founded: "No messages found",
          no_chats_founded: "No chats found",
          chat_not_found: "Chat not found",
          user_not_found: "The user you typed does not exist. Try again",
          user_not_registered: "The user is not registered in the system",
          user_logged_in: "User is logged in the system, do logout to continue",
          user_not_logged_in: "User not logged in",

          user_not_in_voice_channel: "You are not in a voice channel.",
          bot_not_in_voice_channel: "The bot is not in a voice channel.",

          message_history_too_long: "The message history is too long.",
          text_length_too_long: "The response text is too long. Try to reduce the number of responses in the same message.",

          invalid_command: "Invalid command. Try again.",
          something_went_wrong: "Something went wrong. Try again later."
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

      def help_message_discord_en
        ["To start talking to me, type #{discord_prefix}start",
         "To stop talking to me, type #{discord_prefix}stop",
         "To register in the system, type #{discord_prefix}register email:password (the password must be a 4 digit number ex: 1234)",
         "To log in to the system, type #{discord_prefix}login email:password (the password must be a 4 digit number ex: 1234)",
         "To create a new chat, type #{discord_prefix}new_chat chat name",
         "To select a chat, type #{discord_prefix}sl_chat chat name",
         "To list the chats you created, type #{discord_prefix}list",
         "To see this message again, type #{discord_prefix}help"]
      end
  end
end
