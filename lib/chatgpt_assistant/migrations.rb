# frozen_string_literal: true

require "active_record"
require "active_model"

# Email model
class UserMigration < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :users

    create_table :users do |t|
      t.string :email, null: false, limit: 100
      t.string :password, null: false, limit: 4
      t.string :name, null: false, limit: 100
      t.string :telegram_id, limit: 100
      t.string :discord_id, limit: 100
      t.integer :current_chat_id, null: false, default: 0
      t.integer :role, null: false, default: 0
      t.integer :open_chats, null: false, default: 0
      t.integer :closed_chats, null: false, default: 0
      t.integer :total_chats, null: false, default: 0
      t.integer :total_messages, null: false, default: 0
      t.timestamps
    end
  end
end

class ChatMigration < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :chats

    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.text :title, null: false, default: "", limit: 100
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end

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
