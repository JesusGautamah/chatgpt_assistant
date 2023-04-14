RSpec.describe ChatgptAssistant::AudioRecognition do
  describe "#initialize" do
    it "creates a new instance of AudioRecognition with an openai api key" do
      openai_api_key = "fake-api-key"
      audio_recognition = ChatgptAssistant::AudioRecognition.new(openai_api_key)

      expect(audio_recognition).to be_an_instance_of(ChatgptAssistant::AudioRecognition)
      expect(audio_recognition.instance_variable_get(:@openai_api_key)).to eq(openai_api_key)
    end
  end

  describe "#transcribe_audio" do
    let(:audio_url) { "https://example.com/audio.oga" }
    let(:dl_file_name) { "voice/audio-#{Time.now.to_i}.oga" }
    let(:file_name) { "voice/audio-#{Time.now.to_i}.mp3" }
    let(:openai_api_key) { "fake-api-key" }
    let(:transcription_text) { "transcription text" }
    let(:response_body) { { "text" => transcription_text }.to_json }
    let(:header) do
      {
        "Content-Type": "multipart/form-data",
        Authorization: "Bearer #{openai_api_key}"
      }
    end
    let(:payload) do
      {
        file: Faraday::UploadIO.new(file_name, "audio/mp3"),
        model: "whisper-1"
      }
    end
    let(:audio_recognition) { ChatgptAssistant::AudioRecognition.new(openai_api_key) }

    before do
      allow(Faraday).to receive(:new).and_return(Faraday.new)
      allow(Faraday.new).to receive(:post).and_return(double("response", body: response_body))
      allow(File).to receive(:binwrite).with(dl_file_name, anything)
      allow(File).to receive(:delete).with(dl_file_name)
      allow(FFMPEG::Movie).to receive_message_chain(:new, :transcode)
    end

    # it "downloads the audio, transcodes it, and transcribes the audio using OpenAI API" do
    #   expect(Faraday).to receive(:new).with(url: audio_url).and_return(Faraday.new)
    #   expect(File).to receive(:binwrite).with(dl_file_name, anything)
    #   expect(FFMPEG::Movie).to receive_message_chain(:new, :transcode).with(file_name)
    #   expect(Faraday.new).to receive(:get).and_return(double("response", body: "fake-audio-body"))
    #   expect(Faraday.new).to receive(:post).with("v1/audio/transcriptions", payload, header)

    #   audio_recognition.transcribe_audio(audio_url)

    #   expect(audio_recognition.instance_variable_get(:@response).body).to eq(response_body)
    #   expect(audio_recognition.transcribe_audio(audio_url)).to eq({ file: file_name, text: transcription_text })
    # end
  end
end
