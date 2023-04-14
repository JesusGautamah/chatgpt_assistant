# frozen_string_literal: true

require "active_record"

# Visitor model
class Visitor < ActiveRecord::Base
  has_many :visitor_actions
  validates :name, presence: true
  validates :platform, presence: true
  enum platform: { telegram: 0, discord: 1 }

  def tel_user
    User.find_by(telegram_id: telegram_id)
  end

  def dis_user
    User.find_by(discord_id: discord_id)
  end
end

# User model
class User < ActiveRecord::Base
  attr_accessor :password

  belongs_to :tel_visitor, optional: true, foreign_key: "telegram_id", class_name: "Visitor"
  belongs_to :dis_visitor, optional: true, foreign_key: "discord_id", class_name: "Visitor"
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 100 }
  validates :role, presence: true
  validates :open_chats, presence: true
  validates :closed_chats, presence: true
  validates :total_chats, presence: true
  validates :total_messages, presence: true
  validates :password, presence: true

  before_save :encrypt_password

  has_many :chats
  

  def encrypt_password
    return if password.nil?

    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def current_chat
    chats.find(current_chat_id)
  end

  def last_chat
    chats.last
  end

  def chat_by_title(title)
    chats.find_by(title: title)
  end
end

# Chat model
class Chat < ActiveRecord::Base
  validates :user_id, presence: true
  validates :status, presence: true
  validates :title, presence: true

  belongs_to :user
  has_many :messages

  after_create :init_chat_if_actor_provided

  def init_chat_if_actor_provided
    return if actor.nil?

    messages.create(content: prompt, role: "user")
    messages.create(content: "Hello, I'm #{actor}. I will follow #{prompt}", role: "assistant")
  end
end

# Message model
class Message < ActiveRecord::Base
  validates :content, presence: true
  enum role: { user: 0, assistant: 1 }

  belongs_to :chat
end

# Error model
class Error < ActiveRecord::Base
  validates :message, presence: true
  validates :backtrace, presence: true
end
