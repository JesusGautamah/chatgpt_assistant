# frozen_string_literal: true

# RSpec.describe ChatgptAssistant::DiscordVoiceHelper do
#   let(:dummy_class) { Class.new { include ChatgptAssistant::DiscordVoiceHelper } }
#   let(:instance) { dummy_class.new }

#   describe "#voice_connect_checker_action" do
#     context "when user is not logged in" do
#       before { allow(instance).to receive(:user).and_return(nil) }

#       it "sends user_not_logged_in error message" do
#         expect(instance).to receive(:send_message).with("user_not_logged_in error message")
#         instance.voice_connect_checker_action
#       end
#     end

#     context "when user is logged in but chat is not found" do
#       before do
#         allow(instance).to receive(:user).and_return("user")
#         allow(instance).to receive(:chat).and_return(nil)
#       end

#       it "sends chat_not_found error message" do
#         expect(instance).to receive(:send_message).with("chat_not_found error message")
#         instance.voice_connect_checker_action
#       end
#     end
#   end

#   describe "#voice_connection_checker_action" do
#     context "when user is not in a voice channel" do
#       before do
#         allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(nil)
#         allow(instance).to receive(:user).and_return("user")
#       end

#       it "sends user_not_in_voice_channel error message" do
#         expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#         instance.voice_connection_checker_action
#       end
#     end

#     context "when bot is already connected to a voice channel" do
#       before do
#         allow(instance).to receive(:evnt).and_return(double(voice: true))
#         allow(instance).to receive(:user).and_return("user")
#       end

#       it "sends bot_already_connected error message" do
#         expect(instance).to receive(:send_message).with("bot_already_connected error message")
#         instance.voice_connection_checker_action
#       end
#     end
#   end

#   describe "#speak_connect_checker_action" do
#     context "when user is not logged in" do
#       before { allow(instance).to receive(:user).and_return(nil) }

#       it "sends user_not_logged_in error message" do
#         expect(instance).to receive(:send_message).with("user_not_logged_in error message")
#         instance.speak_connect_checker_action
#       end
#     end

#     context "when user is logged in, in a voice channel and bot is already connected" do
#       before do
#         allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#         allow(instance).to receive(:evnt).and_return(double(voice: true))
#         allow(instance).to receive(:user).and_return("user")
#         allow(instance).to receive(:chat).and_return(nil)
#       end

#       it "sends chat_not_found error message" do
#         expect(instance).to receive(:send_message).with("chat_not_found error message")
#         instance.speak_connect_checker_action
#       end
#     end
#   end

#   describe "#speak_connection_checker_action" do
#     context "when user is not in a voice channel" do
#       before do
#         allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(nil)
#         allow(instance).to receive(:user).and_return "user"
#       end

#       it "sends user_not_in_voice_channel error message" do
#         expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#         instance.speak_connection_checker_action
#       end

#       context "when user is in a voice channel but bot is not connected" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: false))
#           allow(instance).to receive(:user).and_return "user"
#         end

#         it "sends bot_not_connected error message" do
#           expect(instance).to receive(:send_message).with("bot_not_connected error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel and bot is connected" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#         end

#         it "sends bot_not_connected error message" do
#           expect(instance).to receive(:send_message).with("bot_not_connected error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected and chat is not found" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return nil
#         end

#         it "sends chat_not_found error message" do
#           expect(instance).to receive(:send_message).with("chat_not_found error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected and chat is found" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#         end

#         it "sends chat_not_found error message" do
#           expect(instance).to receive(:send_message).with("chat_not_found error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found and user is not in chat" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return false
#         end

#         it "sends user_not_in_chat error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_chat error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found and user is in chat" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return true
#         end

#         it "sends user_not_in_chat error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_chat error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found, user is in chat and user is not in voice channel" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return false
#         end

#         it "sends user_not_in_voice_channel error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found, user is in chat and user is in voice channel" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#         end

#         it "sends user_not_in_voice_channel error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found, user is in chat, user is in voice channel and user is not in voice channel" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return false
#         end

#         it "sends user_not_in_voice_channel error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found, user is in chat, user is in voice channel and user is in voice channel" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#         end

#         it "sends user_not_in_voice_channel error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found, user is in chat, user is in voice channel, user is in voice channel and user is not in voice channel" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return false
#         end

#         it "sends user_not_in_voice_channel error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#           instance.speak_connection_checker_action
#         end
#       end

#       context "when user is in a voice channel, bot is connected, chat is found, user is in chat, user is in voice channel, user is in voice channel and user is in voice channel" do
#         before do
#           allow(instance).to receive_message_chain(:evnt, :user, :voice_channel).and_return(double)
#           allow(instance).to receive(:evnt).and_return(double(voice: true))
#           allow(instance).to receive(:user).and_return "user"
#           allow(instance).to receive(:chat).and_return double
#           allow(instance).to receive(:user_in_chat?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#           allow(instance).to receive(:user_in_voice_channel?).and_return true
#         end

#         it "sends user_not_in_voice_channel error message" do
#           expect(instance).to receive(:send_message).with("user_not_in_voice_channel error message")
#           instance.speak_connection_checker_action
#         end
#       end
#     end
#   end
# end
