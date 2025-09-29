# frozen_string_literal: true

module MySQL
  module Search
    # Railtie for integrating MySQL::Search with Rails applications.
    class Railtie < Rails::Railtie
      railtie_name :mysql_search

      config.to_prepare do
        MySQL::Search.load_source_classes! if MySQL::Search.autoload_sources
      end

      rake_tasks do
        load 'tasks/mysql/search/actualize.rake'
        load 'tasks/mysql/search/reindex.rake'
      end

      generators do
        require 'generators/mysql/search/install_generator'
      end
    end
  end
end
