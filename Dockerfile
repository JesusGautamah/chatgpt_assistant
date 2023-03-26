FROM ruby:3.2.0
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client ffmpeg
WORKDIR /telegram_chatgpt
COPY Gemfile /telegram_chatgpt/Gemfile
COPY Gemfile.lock /telegram_chatgpt/Gemfile.lock
RUN bundle install