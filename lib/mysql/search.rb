# frozen_string_literal: true

require_relative 'search/callbacks'
require_relative 'search/grabber'
require_relative 'search/jobs'
require_relative 'search/searchable'
require_relative 'search/source'
require_relative 'search/queries/updated_sources_query'
require_relative 'search/queries/full_text_search_query'
require_relative 'search/updater'
require_relative 'search/utils'

module MySQL
  # Provides a namespace for MySQL search functionality.
  module Search
    module_function

    # Runtime configuration
    mattr_accessor :automatic_update, default: true
    mattr_accessor :update_asyncronously, default: false

    # Search Index & Sources
    mattr_accessor :search_index_class_name, default: 'SearchIndex'
    mattr_accessor :sources_path, default: 'app/search_sources'

    # Formatters
    mattr_accessor :calendar_week_format, default: 'week %V'
    mattr_accessor :date_format, default: '%d.%m.%Y'

    def register_format(name, &)
      Utils::Formatter.register(name, &)
    end

    def search_index_class
      @search_index_class ||= search_index_class_name.constantize
    end

    def source_classes
      @source_classes ||= Dir.glob("#{sources_path}/**/*.rb").filter_map do |file|
        file.sub("#{sources_path}/", '').sub('.rb', '').camelize.safe_constantize
      end
    end

    def configure
      yield self
    end
  end
end

# Load Railtie if Rails is defined
require_relative 'search/railtie' if defined?(Rails::Railtie)
