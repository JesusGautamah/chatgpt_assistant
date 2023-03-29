# Chatgpt Assistant

This ruby gem is an way to easy initialize an client of Telegram and Discord bots with the ChatGPT API, Audio Transcription, IBM CLoud Text to Speech and AWS Polly, creating an assistant that can answer questions in text and voice, speak the answers, and have a conversation with the user.

## Requirements
  - Ruby > 2.6.0
  - Docker
  - Docker Compose

# Installation
You can install this as a gem, and use the cli to copy the files to desired folder, or you can just clone/fork this repo and use it as you want.

## Installation as a gem
Run in your terminal:

      gem install chatgpt_assistant
      chatgpt_assistant PATH_TO_FOLDER

## Installation as a repo
Run in your terminal:

      git clone https://github.com/JesusGautamah/chatgpt_assistant.git

# Usage
## Environment variables
You have to rename the .env_sample file to .env and fill the variables with your own data.

## Build the bot
Run in your terminal inside the project folder:

      rake compose:build

## Run the bot

      rake compose:up

## Tail the logs

      rake compose_logs:tail_all

## More commands at https://github.com/JesusGautamah/lucy_dockerunner

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JesusGautamah/chatgpt_assistant. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/JesusGautamah/chatgpt_assistant/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ChatgptAssistant project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/JesusGautamah/chatgpt_assistant/blob/master/CODE_OF_CONDUCT.md).
