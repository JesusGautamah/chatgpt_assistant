# # frozen_string_literal: true

# RSpec.describe ChatgptAssistant::TelegramVoiceHelper do
#   let(:config) { ChatgptAssistant::Config.new }
#   let(:dummy_class) { ChatgptAssistant::TelegramBot.new(config) }
#   let(:bot) { 
#   let(:msg) { double("msg", chat: double("chat", id: 123), audio: nil, voice: nil) }
#   let(:user) { double("user", current_chat_id: 123) }
#   let(:chatter) { double("chatter") }
#   let(:synthesis) { double("synthesis") }

#   before do
#     allow(bot).to receive_message_chain(:api, :get_file)
#     allow(bot).to receive_message_chain(:api, :send_voice)
#     allow(chatter).to receive(:chat)
#     allow(synthesis).to receive(:synthesize_text)
#   end

#   describe "#telegram_audio_info" do
#     it "calls Telegram API to get audio file info" do
#       expect(bot.api).to receive(:get_file).with(file_id: nil)
#       subject.telegram_audio_info
#     end
#   end

#   describe "#telegram_audio_url" do
#     it "returns the URL of the audio file" do
#       allow(subject).to receive(:telegram_audio_info).and_return({ "result" => { "file_path" => "path/to/audio.mp3" } })
#       expect(subject.telegram_audio_url).to eq("https://api.telegram.org/file/bot/nil/path/to/audio.mp3")
#     end
#   end

#   describe "#telegram_audio" do
#     it "returns the audio message if present" do
#       allow(msg).to receive(:audio).and_return("audio")
#       expect(subject.telegram_audio).to eq("audio")
#     end

#     it "returns the voice message if audio is not present" do
#       allow(msg).to receive(:voice).and_return("voice")
#       expect(subject.telegram_audio).to eq("voice")
#     end
#   end

#   describe "#telegram_process_ai_voice" do
#     let(:user_audio) { { "text" => "hello" } }

#     it "calls chatter to get AI response" do
#       expect(chatter).to receive(:chat).with("hello", 123, anything)
#       subject.telegram_process_ai_voice(user_audio)
#     end

#     it "calls synthesis to generate AI voice" do
#       allow(chatter).to receive(:chat).and_return("response")
#       expect(synthesis).to receive(:synthesize_text).with("response")
#       subject.telegram_process_ai_voice(user_audio)
#     end

#     it "returns the AI voice and text" do
#       allow(chatter).to receive(:chat).and_return("response")
#       allow(synthesis).to receive(:synthesize_text).and_return("voice")
#       expect(subject.telegram_process_ai_voice(user_audio)).to eq({ voice: "voice", text: "response" })
#     end
#   end

#   describe "#telegram_send_voice_message" do
#     let(:voice) { "path/to/voice.mp3" }
#     let(:text) { "hello" }

#     it "sends the voice message to Telegram API" do
#       expect(bot.api).to receive(:send_voice).with(chat_id: 123, voice: anything)
#       subject.telegram_send_voice_message(voice: voice, text: text)
#     end

#     it "sends the text message to Telegram API" do
#       expect(subject).to receive(:send_message).with("hello", 123)
#       subject.telegram_send_voice_message(voice: voice, text: text)
#     end

#     it "splits long text messages into multiple messages" do
#       long_text = "a" * 5000
#       expect(subject).to receive(:send_message).twice
#       subject.telegram_send_voice_message(voice: voice, text: long_text)
#     end
#   end
# end
