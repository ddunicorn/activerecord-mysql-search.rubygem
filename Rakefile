# frozen_string_literal: true

require 'bundler/gem_tasks'

load 'tasks/actualize.rake'
load 'tasks/reindex.rake'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[spec rubocop]
