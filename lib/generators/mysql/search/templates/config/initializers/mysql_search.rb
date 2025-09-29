# frozen_string_literal: true

# Configure MySQL::Search settings
MySQL::Search.configure do |config|
  # Model class name for search indices (default: 'SearchIndex')
  # config.search_index_class_name = 'SearchIndex'

  # Path to search source classes (default: 'app/search_sources')
  # config.sources_path = 'app/search_sources'

  # Automatically load source classes on Rails startup (default: true)
  # Loading of source classes assigns callbacks to the target models
  # to keep the search index updated. In case of loading issue you can load
  # the source classes manually with `MySQL::Search.load_source_classes!`
  # and disable automatic initialization.
  # config.autoload_sources = true

  # Automatically update search index when models change (default: true)
  # config.automatic_update = true

  # Process index updates asynchronously (default: false)
  # config.update_asyncronously = false

  # Date format for date fields (default: '%d.%m.%Y')
  # config.date_format = '%d.%m.%Y'

  # Calendar week format (default: 'week %V')
  # config.calendar_week_format = 'week %V'

  # Register custom formatters
  # config.register_format(:upcase) { |value| value.to_s.upcase }
end
