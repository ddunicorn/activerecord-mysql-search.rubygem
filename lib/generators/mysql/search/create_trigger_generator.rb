# frozen_string_literal: true

# Generates an initializer file for the MySQL Search gem
module MySQL
  module Search
    # This generator creates a migration to add a trigger for automatically updating the `updated_at` column in MySQL.
    # It also includes a monkey-patch for ActiveRecord's `#timestamps` method to use
    # MySQL's `DATETIME ON UPDATE CURRENT_TIMESTAMP` for the `updated_at` column.
    class CreateTriggerGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      namespace 'mysql:search:create_trigger'
      source_root File.expand_path('templates', __dir__)

      def self.next_migration_number(_path)
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      end

      desc 'Generates migration to add a trigger to automatically update the `updated_at` ' \
           'column in MySQL + ActiveRecord monkey-patch for `#timestamps`'
      def create_config_and_migration_files
        migration_template 'db/migrate/enable_auto_update_of_updated_at.rb',
                           'db/migrate/enable_auto_update_of_updated_at.rb'
        template 'config/initializers/active_record_ext.rb'
      end
    end
  end
end
