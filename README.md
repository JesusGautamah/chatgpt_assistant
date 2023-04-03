# ChatGPT Assistant

[![Gem Version](https://badge.fury.io/rb/chatgpt_assistant.svg)](https://badge.fury.io/rb/chatgpt_assistant)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby Version](https://img.shields.io/badge/Ruby-2.6.0%2B-blue.svg)](https://www.ruby-lang.org/en/)

This Ruby gem provides an easy way to initialize a client for Telegram and Discord bots using the ChatGPT API, audio transcription, IBM Cloud Text to Speech, and AWS Polly, creating an assistant that can answer questions in text and voice and have a conversation with the user.

#### Languages supported currently: en, pt - contributions are welcome!
You can contribute by adding your language to the DefaultMessages class in lib/chatgpt_assistant/default_messages.rb. You can also add your language to the list of languages in the README.md file.
Pull request from language/YOUR_LANGUAGE to main, remember to name your pull request as "Add YOUR_LANGUAGE support".

Other contributions are welcome too!
Remember to give a star to this repo if you like it!
## Requirements

- Ruby > 2.6.0
- Docker
- Docker Compose
- PostgreSQL
- Telegram Bot API Token
- Discord Bot API Token
- IBM Cloud Text to Speech API Key or AWS Polly API Key
- OpenAI API Key

## Installation

To install the gem, run:

```bash
gem install chatgpt_assistant
```

Alternatively, you can clone/fork this repo to use it as you wish.

## Installation as a gem example

```bash
gem install chatgpt_assistant
chatgpt_assistant PATH_TO_FOLDER
cd PATH_TO_FOLDER
cp .env_sample .env
bundle install
```

## Installation as a repo
Run in your terminal:
```bash
git clone https://github.com/JesusGautamah/chatgpt_assistant.git
cd chatgpt_assistant
cp .env_sample .env
bundle install
```

Make sure to run bundle before using the Lucy Dockerunner rake tasks.

Then, edit the .env_sample file to include the necessary credentials and rename it to .env. Run bundle install to install the necessary dependencies.

Remember to edit docker-compose.prod.yml when deploying to production.

## Migrate your database
```bash
rake compose:up && sudo docker compose run --rm telegram exe/chatgpt_bot migrate
```

## Usage

You can start the Docker Compose services required for the gem using the rake tasks provided by the Lucy Dockerunner gem. These tasks include compose:up, compose:down, compose:status, compose:shell, compose:restart, and others listed previously.

For example, to start the services, run:

```bash
rake compose:up
```


To stop the services, run:

```bash
rake compose:down
```

After starting the Docker Compose services, you can use the features of the gem to create a chat assistant that responds to questions in both text and voice using the services mentioned above.

#### More compose rake tasks at https://github.com/JesusGautamah/lucy_dockerunner

## Discord Bot Commands

- !start - shows the welcome message
- !help - shows the help message
- !login email:password - logs in the user
- !register email:password - registers a new user
- !list - lists the user created chatbots
- !sl_chat CHAT TITLE - starts a chat with the chatbot with the given title
- !new_chat CHAT TITLE - creates a new chatbot with the given title
- !ask TEXT - sends a text to the chatbot
- !connect - connects the chat bot to the current channel
- !disconnect - disconnects the chat bot from the current channel
- !speak TEXT - sends a text to the chatbot and gets the response in voice

## Telegram Bot Commands

- /start - shows the welcome message
- /help - shows the help message
- login/email:password - logs in the user
- register/email:password - registers a new user
- list - lists the user created chatbots
- sl_chat/CHAT TITLE - starts a chat with the chatbot with the given title
- new_chat/CHAT TITLE - creates a new chatbot with the given title
- TEXT - sends a text to the chatbot
- VOICE_MESSAGE or AUDIO FILE - sends a voice message to the chatbot and returns the response in voice

## Recommended Actions runner

You can run Github Actions workflows locally using [act](https://github.com/nektos/act)

We recommend Act installation to run Github Actions workflows locally
as we use it to deploy the bot in a server via ssh.

## Contributing

A good way to contribute is add your language to DefaultMessages class in lib/chatgpt_assistant/default_messages.rb. You can also add your language to the list of languages in the README.md file.

Bug reports and pull requests are welcome on GitHub at https://github.com/JesusGautamah/chatgpt_assistant. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/JesusGautamah/chatgpt_assistant/blob/master/CODE_OF_CONDUCT.md).


## [![Repography logo](https://images.repography.com/logo.svg)](https://repography.com) / Recent activity [![Time period](https://images.repography.com/33522702/JesusGautamah/chatgpt_assistant/recent-activity/y6ZDduNWHwPzbnUFsmdGrJ99Q1vyEKGOBWFOBvzGjnM/1rZM2QrF0__3eUfUXFe6jDraYjHvypniTqDWhCequ-U_badge.svg)](https://repography.com)
[![Timeline graph](https://images.repography.com/33522702/JesusGautamah/chatgpt_assistant/recent-activity/y6ZDduNWHwPzbnUFsmdGrJ99Q1vyEKGOBWFOBvzGjnM/1rZM2QrF0__3eUfUXFe6jDraYjHvypniTqDWhCequ-U_timeline.svg)](https://github.com/JesusGautamah/chatgpt_assistant/commits)
[![Issue status graph](https://images.repography.com/33522702/JesusGautamah/chatgpt_assistant/recent-activity/y6ZDduNWHwPzbnUFsmdGrJ99Q1vyEKGOBWFOBvzGjnM/1rZM2QrF0__3eUfUXFe6jDraYjHvypniTqDWhCequ-U_issues.svg)](https://github.com/JesusGautamah/chatgpt_assistant/issues)

[![Pull request status graph](https://images.repography.com/33522702/JesusGautamah/chatgpt_assistant/recent-activity/y6ZDduNWHwPzbnUFsmdGrJ99Q1vyEKGOBWFOBvzGjnM/1rZM2QrF0__3eUfUXFe6jDraYjHvypniTqDWhCequ-U_prs.svg)](https://github.com/JesusGautamah/chatgpt_assistant/pulls)
[![Trending topics](https://images.repography.com/33522702/JesusGautamah/chatgpt_assistant/recent-activity/y6ZDduNWHwPzbnUFsmdGrJ99Q1vyEKGOBWFOBvzGjnM/1rZM2QrF0__3eUfUXFe6jDraYjHvypniTqDWhCequ-U_words.svg)](https://github.com/JesusGautamah/chatgpt_assistant/commits)

[![Top contributors](https://images.repography.com/33522702/JesusGautamah/chatgpt_assistant/recent-activity/y6ZDduNWHwPzbnUFsmdGrJ99Q1vyEKGOBWFOBvzGjnM/1rZM2QrF0__3eUfUXFe6jDraYjHvypniTqDWhCequ-U_users.svg)](https://github.com/JesusGautamah/chatgpt_assistant/graphs/contributors)
[![Activity map](https://images.repography.com/33522702/JesusGautamah/chatgpt_assistant/recent-activity/y6ZDduNWHwPzbnUFsmdGrJ99Q1vyEKGOBWFOBvzGjnM/1rZM2QrF0__3eUfUXFe6jDraYjHvypniTqDWhCequ-U_map.svg)](https://github.com/JesusGautamah/chatgpt_assistant/commits)

## Contributors
  - [Jesus Gautamah](https://github.com/JesusGautamah) 

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ChatgptAssistant project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/JesusGautamah/chatgpt_assistant/blob/master/CODE_OF_CONDUCT.md).
