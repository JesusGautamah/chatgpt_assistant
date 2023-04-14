# frozen_string_literal: true

RSpec.describe ChatgptAssistant::Config do
  subject(:config) { described_class.new }

  describe "#openai_api_key" do
    context "when OPENAI_API_KEY is set" do
      before { ENV["OPENAI_API_KEY"] = "secret_key" }

      it "returns the API key" do
        expect(config.openai_api_key).to eq("secret_key")
      end
    end

    context "when OPENAI_API_KEY is not set" do
      before { ENV.delete("OPENAI_API_KEY") }

      # it "raises an error" do
      #   expect { config.openai_api_key }.to raise_error(KeyError)
      # end
    end
  end

  describe "#telegram_token" do
    context "when TELEGRAM_TOKEN is set" do
      before { ENV["TELEGRAM_TOKEN"] = "secret_token" }

      it "returns the token" do
        expect(config.telegram_token).to eq("secret_token")
      end
    end

    context "when TELEGRAM_TOKEN is not set" do
      before { ENV.delete("TELEGRAM_TOKEN") }

      # it "raises an error" do
      #   expect { config.telegram_token }.to raise_error(KeyError)
      # end
    end
  end

  describe "#discord_token" do
    context "when DISCORD_TOKEN is set" do
      before { ENV["DISCORD_TOKEN"] = "secret_token" }

      it "returns the token" do
        expect(config.discord_token).to eq("secret_token")
      end
    end

    context "when DISCORD_TOKEN is not set" do
      before { ENV.delete("DISCORD_TOKEN") }

      # it "raises an error" do
      #   expect { config.discord_token }.to raise_error(KeyError)
      # end
    end
  end

  describe "#ibm_api_key" do
    context "when IBM_API_KEY is set" do
      before { ENV["IBM_API_KEY"] = "secret_key" }

      it "returns the API key" do
        expect(config.ibm_api_key).to eq("secret_key")
      end
    end

    context "when IBM_API_KEY is not set" do
      before { ENV.delete("IBM_API_KEY") }

      # it "raises an error" do
      #   expect { config.ibm_api_key }.to raise_error(KeyError)
      # end
    end
  end

  describe "#ibm_url" do
    context "when IBM_URL is set" do
      before { ENV["IBM_URL"] = "https://example.com/api" }

      it "returns the URL" do
        expect(config.ibm_url).to eq("https://example.com/api")
      end
    end

    context "when IBM_URL is not set" do
      before { ENV.delete("IBM_URL") }

      # it "raises an error" do
      #   expect { config.ibm_url }.to raise_error(KeyError)
      # end
    end
  end

  describe "#aws_access_key_id" do
    context "when AWS_ACCESS_KEY_ID is set" do
      before { ENV["AWS_ACCESS_KEY_ID"] = "access_key_id" }

      it "returns the access key ID" do
        expect(config.aws_access_key_id).to eq("access_key_id")
      end
    end

    context "when AWS_ACCESS_KEY_ID is not set" do
      before { ENV.delete("AWS_ACCESS_KEY_ID") }

      # it "raises an error" do
      #   expect { config.aws_access_key_id }.to raise_error(KeyError)
      # end
    end
  end

  describe "#aws_secret_access_key" do
    context "when AWS_SECRET_ACCESS_KEY is set" do
      before { ENV["AWS_SECRET_ACCESS_KEY"] = "XXXXXXXXXXXXXXXXXXXX" }

      it "returns the secret access key" do
        expect(config.aws_secret_access_key).to eq "XXXXXXXXXXXXXXXXXXXX"
      end
    end

    context "when AWS_SECRET_ACCESS_KEY is not set" do
      before { ENV.delete("AWS_SECRET_ACCESS_KEY") }

      # it "raises an error" do
      #   expect { config.aws_secret_access_key }.to raise_error(KeyError)
      # end
    end
  end
end
