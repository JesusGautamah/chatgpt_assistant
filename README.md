# ChatGPT Assistant

This Ruby gem provides an easy way to initialize a client for Telegram and Discord bots using the ChatGPT API, audio transcription, IBM Cloud Text to Speech, and AWS Polly, creating an assistant that can answer questions in text and voice and have a conversation with the user.

## Requirements

- Ruby > 2.6.0
- Docker
- Docker Compose

## Installation

To install the gem, run:

```bash
gem install chatgpt_assistant
```

Alternatively, you can clone/fork this repo to use it as you wish.

### Installation as a gem example

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

## Usage

You can start the Docker Compose services required for the gem using the rake tasks provided by the Lucy Dockerunner gem. These tasks include compose:up, compose:down, compose:status, compose:shell, compose:restart, and others listed previously.

For example, to start the services, run:

```ruby
rake compose:up
```


To stop the services, run:

```ruby
rake compose:down
```

After starting the Docker Compose services, you can use the features of the gem to create a chat assistant that responds to questions in both text and voice using the services mentioned above.

## More commands at https://github.com/JesusGautamah/lucy_dockerunner

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JesusGautamah/chatgpt_assistant. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/JesusGautamah/chatgpt_assistant/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ChatgptAssistant project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/JesusGautamah/chatgpt_assistant/blob/master/CODE_OF_CONDUCT.md).
