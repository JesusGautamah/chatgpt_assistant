# frozen_string_literal: true

require "active_record"

class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :name, presence: true
  validates :role, presence: true
  validates :open_chats, presence: true
  validates :closed_chats, presence: true
  validates :total_chats, presence: true
  validates :total_messages, presence: true

  has_many :chats
end

class Chat < ActiveRecord::Base
  validates :user_id, presence: true
  validates :status, presence: true
  validates :title, presence: true

  belongs_to :user
  has_many :messages
end

class Message < ActiveRecord::Base
  validates :content, presence: true
  enum role: { user: 0, assistant: 1 }

  belongs_to :chat
end
