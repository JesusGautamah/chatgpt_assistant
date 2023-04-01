# frozen_string_literal: true

require "active_record"

# User model
class User < ActiveRecord::Base
  before_save :generate_password_salt
  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validates :name, presence: true
  validates :role, presence: true
  validates :open_chats, presence: true
  validates :closed_chats, presence: true
  validates :total_chats, presence: true
  validates :total_messages, presence: true

  has_many :chats

  def generate_password_salt
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password_hash, password_salt)
  end
end

# Chat model
class Chat < ActiveRecord::Base
  validates :user_id, presence: true
  validates :status, presence: true
  validates :title, presence: true

  belongs_to :user
  has_many :messages
end

# Message model
class Message < ActiveRecord::Base
  validates :content, presence: true
  enum role: { user: 0, assistant: 1 }

  belongs_to :chat
end
