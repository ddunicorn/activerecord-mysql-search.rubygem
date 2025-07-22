# frozen_string_literal: true

require 'mysql/search'

require 'logger'
require 'rake'

require 'active_record'
require 'active_job'

require 'database_cleaner/active_record'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  config.around(:each, :disable_automatic_update) do |example|
    MySQL::Search.automatic_update = false
    example.run
    MySQL::Search.automatic_update = true
  end
end

# Logging
logger = Logger.new("#{File.dirname(__FILE__)}/test.log")
ActiveRecord::Base.logger = logger
ActiveJob::Base.logger = logger

# Database setup, create database manually before running tests
database_config = YAML.load_file("#{File.dirname(__FILE__)}/database.yml")
ActiveRecord::Base.establish_connection(database_config['test'])
require "#{File.dirname(__FILE__)}/database.rb"

# Truncation is required as MySQL builds full text search index on transaction commit
# https://dev.mysql.com/doc/refman/8.4/en/innodb-fulltext-index.html#innodb-fulltext-index-transaction
DatabaseCleaner.strategy = :truncation

# Load all search sources and models
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require File.expand_path(f) }
Dir["#{File.dirname(__FILE__)}/search_sources/*.rb"].each { |f| require File.expand_path(f) }

MySQL::Search.configure do |config|
  config.search_index_class_name = 'SearchIndex'
  config.sources_path = 'spec/search_sources'
  config.automatic_update = true
  config.update_asyncronously = false
end
