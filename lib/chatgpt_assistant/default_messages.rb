# frozen_string_literal: true

module ChatgptAssistant
  # This class is responsible for storing the default messages
  class DefaultMessages
    def self.start_messages
      ["Primeiro, é necessário cadastrar seu usuário no banco de dados. Para isso, mande ume mensgem com seu email e senha de acesso de 4 digitos. Exemplo:",
       "register/email@dousuario.com:1234"]
    end

    def self.end_messages
      ["Até mais!",
       "Se quiser conversar comigo novamente, basta fazer login"]
    end

    def self.help_messages
      ["Para começar a conversar comigo, digite /start",
       "Para parar de conversar comigo, digite /stop",
       "Para se registrar no sistema, digite register/email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
       "Para fazer login no sistema, digite login/email:senha (a senha deve ser um numero de 4 digitos ex: 1234)",
       "Para criar um novo chat, digite novo_chat/nome do chat",
       "Para selecionar um chat, digite sl_chat/nome do chat",
       "Para listar os chats que você criou, digite /listar",
       "Para ver esta mensagem novamente, digite /ajuda"]
    end

    def self.error_messages
      {
        nil: "Não entendi o que você disse. Tente novamente",
        email: "O email que você digitou não é válido. Tente novamente",
        password: "A senha que você digitou não é válida. Tente novamente",
        user: "O usuário que você digitou não existe. Tente novamente"
      }
    end

    def self.welcome_message
      "Olá, eu sou o Focus Bot, um chatbot que usa a API da OpenAI para responder suas perguntas no Telegram."
    end

    def self.chat_creation_success_message
      "Chat criado com sucesso!"
    end

    def self.chat_creation_failed_message
      "Erro ao criar chat!"
    end

    def self.not_logged_in_messages
      ["Você não está logado no sistema. Para começar mande seu email e senha de acesso de 4 digitos. Exemplo de Login:", "login/user@email.com:1234",
       "Para se registrar no sistema, digite register/email:senha (a senha deve ser um numero de 4 digitos ex: 1234). Exemplo de Registro:", "register/email@user.com:1234"]
    end
  end
end
