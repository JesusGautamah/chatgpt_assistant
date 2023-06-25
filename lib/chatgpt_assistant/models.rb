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

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 100 }, on: :create
  validates :role, presence: true, on: :create
  validates :open_chats, presence: true, on: :create
  validates :closed_chats, presence: true, on: :create
  validates :total_chats, presence: true, on: :create
  validates :total_messages, presence: true, on: :create
  validates :password, presence: true, on: :create

  before_save :encrypt_password, if: :password

  has_many :chats

  def encrypt_password
    return if password.nil?

    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def encrypt_token
    confirmation = { email: email, password_hash: password_hash, time: created_at }
    BCrypt::Engine.hash_secret(JSON.parse(confirmation.to_json), password_salt)
  end

  def valid_password?(password)
    BCrypt::Engine.hash_secret(password, password_salt) == password_hash
  end

  def confirm_account(hash)
    confirmation = { email: email, password_hash: password_hash, time: created_at }
    secret = BCrypt::Engine.hash_secret(JSON.parse(confirmation.to_json), password_salt)
    return false unless secret == hash

    self.token = secret
    self.active = true
    save
    true
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

  def chat_history
    current_chat.messages.last(10).map { |m| "#{m.role}: #{m.content}\nat: #{m.created_at}" }
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

    messages.create(content: prompt, role: "system")
  end
end

# Message model
class Message < ActiveRecord::Base
  validates :content, presence: true
  enum role: { user: 0, assistant: 1, system: 2 }

  belongs_to :chat
end

# Error model
class Error < ActiveRecord::Base
  validates :message, presence: true
  validates :backtrace, presence: true
end
