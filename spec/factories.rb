# factories/visitors.rb
FactoryBot.define do
  factory :visitor do
    telegram_id { Faker::Internet.uuid }
    discord_id { Faker::Internet.uuid }
    platform { Visitor.platforms.keys.sample }
    name { Faker::Name.name }
    current_user_id { 0 }
  end
end

# factories/users.rb
FactoryBot.define do
  factory :user do
    telegram_id { nil }
    discord_id { nil }
    email { Faker::Internet.email }
    password { "password" }
    current_chat_id { 0 }
    open_chats { 0 }
    closed_chats { 0 }
    total_chats { 0 }
    total_messages { 0 }
  end
end

# factories/chats.rb
FactoryBot.define do
  factory :chat do
    user { create(:user) }
    title { Faker::Lorem.sentence }
    # status { Chat.statuses.keys.sample }
    messages_count { 0 }
    actor { nil }
    prompt { nil }
  end
end

# factories/messages.rb
FactoryBot.define do
  factory :message do
    chat { create(:chat) }
    role { Message.roles.keys.sample }
    content { Faker::Lorem.sentence }
  end
end

# factories/errors.rb
FactoryBot.define do
  factory :error do
    chat_id { create(:chat).id }
    user_id { create(:user).id }
    message { Faker::Lorem.sentence }
    backtrace { [Faker::Lorem.sentence] }
  end
end