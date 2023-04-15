# frozen_string_literal: true

# RSpec.describe ChatgptAssistant::TelegramBot do
#   let(:config) { ChatgptAssistant::Config.new }
#   let(:bot) { instance_dobChatgptAssistant::TelegramBot.new(config) }
#   let(:message) { instance_double(Telegram::Bot::Types::Message, chat: instance_double(Telegram::Bot::Types::Chat, id: 1)) }
#   let(:
#   describe "#start" do
#     it "listens to private messages", vcr: { cassette_name: "bot/start" } do
#       expect(bot).to receive(:telegram_visited?).with(message.chat.id)
#       expect(bot).to receive(:telegram_text_or_audio?).and_return(true)
#       expect(bot).to receive(:telegram_message_has_text?).and_return(true)
#       expect(bot).to receive(:text_events)
#       bot.start
#     end

#     it "rescues StandardError and retries", vcr: { cassette_name: "bot/start" } do
#       expect(bot).to receive(:telegram_visited?).with(message.chat.id).and_raise(StandardError)
#       expect(bot).to receive(:retry)
#       bot.start
#     end
#   end

#   describe "#text_events" do
#     before do
#       allow(bot).to receive(:msg).and_return(message)
#     end

#     context "when message text is /start" do
#       it "calls start_event" do
#         allow(message).to receive(:text).and_return("/start")
#         expect(bot).to receive(:start_event)
#         bot.send(:text_events)
#       end
#     end

#     context "when message text is /help" do
#       it "calls help_event" do
#         allow(message).to receive(:text).and_return("/help")
#         expect(bot).to receive(:help_event)
#         bot.send(:text_events)
#       end
#     end

#     context "when message text is /hist" do
#       it "calls hist_event" do
#         allow(message).to receive(:text).and_return("/hist")
#         expect(bot).to receive(:hist_event)
#         bot.send(:text_events)
#       end
#     end

#     context "when message text is /list" do
#       it "calls list_event" do
#         allow(message).to receive(:text).and_return("/list")
#         expect(bot).to receive(:list_event)
#         bot.send(:text_events)
#       end
#     end

#     context "when message text is /stop" do
#       it "calls stop_event" do
#         allow(message).to receive(:text).and_return("/stop")
#         expect(bot).to receive(:stop_event)
#         bot.send(:text_events)
#       end
#     end

#     context "when message text is nil" do
#       it "calls nil_event" do
#         allow(message).to receive(:text).and_return(nil)
#         expect(bot).to receive(:nil_event)
#         bot.send(:text_events)
#       end
#     end

#     context "when message text is not a command" do
#       it "calls action_events" do
#         allow(message).to receive(:text).and_return("some text")
#         expect(bot).to receive(:action_events)
#         bot.send(:text_events)
#       end
#     end
#   end

#   describe "#start_event" do
#     it "sends start message" do
#       expect(bot).to receive(:telegram_send_start_message)
#       bot.send(:start_event)
#     end
#   end

#   describe "#help_event" do
#     it "sends help messages" do
#       expect(bot).to receive(:help_messages).and_return(["help message"])
#       expect(bot).to receive(:send_message).with("help message", message.chat.id)
#       bot.send(:help_event)
#     end
#   end

#   describe "#hist_event" do
#     before do
#       allow(bot).to receive(:user).and_return(double("user"))
#     end

#     context "when user is not logged in" do
#       it "sends not logged in message" do
#         expect(bot).to receive(:not_logged_in_message)
#         bot.send(:hist_event)
#       end
#     end

#     context "when user is logged in" do
#       before do
#         allow(bot).to receive(:user).and_return(double("user", current_chat: double("chat", messages: double("messages", count: 1))))
#         allow(bot).to receive(:telegram_user_history).and_return(["history message"])
#       end

#       context "when user has no current chat" do
#         it "sends no chat selected message" do
#           allow(bot).to receive(:user).and_return(double("user", current_chat: nil))
#           expect(bot).to receive(:no_chat_selected_message)
#           bot.send(:hist_event)
#         end
#       end

#       context "when user has current chat" do
#         it "sends user history messages" do
#           expect(bot).to receive(:send_message).with("history message", message.chat.id)
#           bot.send(:hist_event)
#         end

#         context "when user has no messages" do
#           it "sends no messages message" do
#             allow(bot).to receive(:telegram_user_history).and_return([])
#             expect(bot).to receive(:no_messages_message)
#             bot.send(:hist_event)
#           end
#         end
#       end
#     end
#   end
# end
