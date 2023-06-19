# frozen_string_literal: true

require "active_record"
require "active_model"

# Visitor model
class VisitorMigration < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :visitors

    create_table :visitors do |t|
      t.string :telegram_id, limit: 100
      t.string :discord_id, limit: 100
      t.integer :platform, null: false, default: 0
      t.string :name, null: false
      t.integer :current_user_id, default: 0
      t.timestamps
    end
  end
end

# User model
class UserMigration < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :users

    create_table :users do |t|
      t.string :telegram_id, foreign_key: true, class_name: "Visitor"
      t.string :discord_id, foreign_key: true, class_name: "Visitor"
      t.string :name, limit: 100
      t.string :email, null: false, limit: 100
      t.string :phone, limit: 100
      t.string :password_hash, null: false, limit: 100
      t.string :password_salt, null: false, limit: 100
      t.string :token, null: false, limit: 100, default: ""
      t.string :openai_token, null: false, limit: 100, default: ""
      t.integer :current_chat_id, null: false, default: 0
      t.integer :role, null: false, default: 0
      t.integer :open_chats, null: false, default: 0
      t.integer :closed_chats, null: false, default: 0
      t.integer :total_chats, null: false, default: 0
      t.integer :total_messages, null: false, default: 0
      t.boolean :active, null: false, default: false
      t.timestamps
    end
  end
end

# Chat model
class ChatMigration < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :chats

    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.text :title, null: false, default: "", limit: 100
      t.integer :status, null: false, default: 0
      t.integer :messages_count, null: false, default: 0
      t.string :actor
      t.text :prompt
      t.timestamps
    end
  end
end

# Message model
class MessageMigration < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :messages

    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.text :content, null: false, default: ""
      t.timestamps
    end
  end
end

# Error model
class ErrorMigration < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :errors

    create_table :errors do |t|
      t.integer :chat_id
      t.integer :user_id
      t.text :message, null: false, default: ""
      t.text :backtrace, null: false, array: true, default: []
      t.timestamps
    end
  end
end
