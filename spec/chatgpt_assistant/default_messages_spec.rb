# frozen_string_literal: true

RSpec.describe ChatgptAssistant::DefaultMessages do
  let(:default_messages) { described_class.new }

  describe "#load_message_context" do
    it "loads the default messages for common, success, error and help messages" do
      expect(default_messages.common_messages).not_to be_empty
      expect(default_messages.success_messages).not_to be_empty
      expect(default_messages.error_messages).not_to be_empty
      expect(default_messages.help_messages).not_to be_empty
    end
  end

  describe "#common_messages_pt" do
    it "returns common messages in Portuguese language" do
      expect(default_messages.send(:common_messages_pt)).to be_a(Hash)
      expect(default_messages.send(:common_messages_pt)).not_to be_empty
    end
  end

  describe "#success_messages_pt" do
    it "returns success messages in Portuguese language" do
      expect(default_messages.send(:success_messages_pt)).to be_a(Hash)
      expect(default_messages.send(:success_messages_pt)).not_to be_empty
    end
  end

  describe "#error_messages_pt" do
    it "returns error messages in Portuguese language" do
      expect(default_messages.send(:error_messages_pt)).to be_a(Hash)
      expect(default_messages.send(:error_messages_pt)).not_to be_empty
    end
  end

  describe "#help_messages_pt" do
    it "returns help messages in Portuguese language" do
      expect(default_messages.send(:help_messages_pt)).to be_an(Array)
      expect(default_messages.send(:help_messages_pt)).not_to be_empty
    end
  end

  describe "#initialize" do
    context "when language and discord prefix is given" do
      let(:default_messages) { described_class.new("pt", "?") }

      it "sets the language and discord prefix" do
        expect(default_messages.language).to eq("pt")
      end
    end

    context "when no arguments are given" do
      it "sets the default language and discord prefix" do
        expect(default_messages.language).to eq("en")
      end
    end
  end
end

RSpec.describe ChatgptAssistant::DefaultMessages do
  let(:default_messages) { described_class.new }

  describe "#load_message_context" do
    it "loads the default messages for common, success, error and help messages" do
      expect(default_messages.common_messages).not_to be_empty
      expect(default_messages.success_messages).not_to be_empty
      expect(default_messages.error_messages).not_to be_empty
      expect(default_messages.help_messages).not_to be_empty
    end
  end

  describe "#common_messages_en" do
    it "returns common messages in English language" do
      expect(default_messages.send(:common_messages_en)).to be_a(Hash)
      expect(default_messages.send(:common_messages_en)).not_to be_empty
    end
  end

  describe "#success_messages_en" do
    it "returns success messages in English language" do
      expect(default_messages.send(:success_messages_en)).to be_a(Hash)
      expect(default_messages.send(:success_messages_en)).not_to be_empty
    end
  end

  describe "#error_messages_en" do
    it "returns error messages in English language" do
      expect(default_messages.send(:error_messages_en)).to be_a(Hash)
      expect(default_messages.send(:error_messages_en)).not_to be_empty
    end
  end

  describe "#help_messages_en" do
    it "returns help messages in English language" do
      expect(default_messages.send(:help_messages_en)).to be_an(Array)
      expect(default_messages.send(:help_messages_en)).not_to be_empty
    end
  end

  describe "#initialize" do
    context "when language and discord prefix is given" do
      let(:default_messages) { described_class.new("en", "?") }

      it "sets the language and discord prefix" do
        expect(default_messages.language).to eq("en")
      end
    end

    context "when no arguments are given" do
      it "sets the default language and discord prefix" do
        expect(default_messages.language).to eq("en")
      end
    end
  end
end
