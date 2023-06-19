# frozen_string_literal: true

# require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "lucy_dockerunner"
require "awesome_chatgpt_actors"
require "dotenv/load"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

LucyDockerunner.load_tasks
AwesomeChatgptActors.load_tasks
