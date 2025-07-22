# frozen_string_literal: true

# Generates an initializer file for the MySQL Search gem
module MySQL
  module Search
    # This generator creates an initializer file for configuring MySQL Search.
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      namespace 'mysql:search:install'
      source_root File.expand_path('templates', __dir__)

      def self.next_migration_number(_path)
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      end

      desc 'Creates an initializer file for MySQL Search configuration'
      def create_config_and_migration_files
        template 'config/initializers/mysql_search.rb'
        template 'app/models/search_index.rb'
        migration_template 'db/migrate/create_search_indices.rb', 'db/migrate/create_search_indices.rb'
      end
    end
  end
end
