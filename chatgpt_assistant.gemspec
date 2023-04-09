# frozen_string_literal: true

require_relative "lib/chatgpt_assistant/version"

Gem::Specification.new do |spec|
  spec.name = "chatgpt_assistant"
  spec.version = ChatgptAssistant::VERSION
  spec.authors = ["JesusGautamah"]
  spec.email = ["lima.jesuscc@gmail.com"]

  spec.summary = "Easy way chatbot with Chatgpt, Telegram bot, Discord bot, currently using GPT-3.5-turbo,
  Audio Transcription and IBM Cloud Text to Speech or AWS Polly in docker containers."

  spec.description = "This gem has the intention to facilitate the creation of chatbots with  Chatgpt,
  Telegram bot, Discord bot, Audio Transcription and IBM Cloud Text to Speech or AWS Polly in docker containers.
  Documentation: https://github.com/JesusGautamah/chatgpt_assistant"

  spec.homepage = "https://github.com/JesusGautamah/chatgpt_assistant"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}.git"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
