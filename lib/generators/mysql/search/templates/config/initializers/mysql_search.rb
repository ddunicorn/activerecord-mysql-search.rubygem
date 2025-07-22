# frozen_string_literal: true

# Configure MySQL::Search settings
MySQL::Search.configure do |config|
  # Defines the name of the search index activerecord model.
  config.search_index_class_name = 'SearchIndex'

  # Location of the search sources folder
  config.sources_path = 'app/search_sources'

  # Enables the search index to be automatically updated via source and nested models callbacks "on save"
  config.automatic_update = true

  # Use ActiveJob to update the search index in the background
  config.update_asyncronously = true

  # Defines the format for `calendar_week` formatter.
  config.calendar_week_format = 'week %W'

  # Defines the format for `date` formater.
  config.date_format = '%d.%m.%Y'
end
