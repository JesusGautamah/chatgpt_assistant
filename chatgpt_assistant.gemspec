# frozen_string_literal: true

require_relative "lib/chatgpt_assistant/version"

Gem::Specification.new do |spec|
  spec.name = "chatgpt_assistant"
  spec.version = ChatgptAssistant::VERSION
  spec.authors = ["JesusGautamah"]
  spec.email = ["lima.jesuscc@gmail.com"]

  spec.summary = "Easy way chatbot with GPT-3.5-turbo, Telegram bot, Discord bot,
  Audio Transcription and IBM Cloud Text to Speech."

  spec.description = "This gem has the intention to facilitate the creation of chatbots with GPT-3.5-turbo,
  Telegram bot, Discord bot, Audio Transcription and IBM Cloud Text to Speech in docker containers."

  spec.homepage = "https://github.com/JesusGautamah/chatgpt_assistant"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}.git"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
