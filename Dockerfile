FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client ffmpeg
WORKDIR /assistant
COPY Gemfile /assistant/Gemfile
COPY Gemfile.lock /assistant/Gemfile.lock
RUN bundle install

RUN apt-get install -y wget
RUN wget https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
RUN tar -xvf opus-1.3.1.tar.gz
RUN cd opus-1.3.1 && ./configure && make && make install
RUN rm -rf opus-1.3.1.tar.gz opus-1.3.1

RUN wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz
RUN tar -xvf libsodium-1.0.18.tar.gz
RUN cd libsodium-1.0.18 && ./configure && make && make install
RUN rm -rf libsodium-1.0.18.tar.gz libsodium-1.0.18
