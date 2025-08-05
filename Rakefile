# frozen_string_literal: true

require 'bundler/gem_tasks'

load 'tasks/mysql/search/actualize.rake'
load 'tasks/mysql/search/reindex.rake'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[spec rubocop]
