# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    # Overrides the default `add_timestamps` method to use MySQL's `DATETIME ON UPDATE CURRENT_TIMESTAMP`
    # for the `updated_at` column.
    # This allows the `updated_at` column to automatically update its value whenever the row is updated.
    module SchemaStatements
      def add_timestamps(table_name, **options)
        options[:null] = false if options[:null].nil?

        options[:precision] = 6 if !options.key?(:precision) && supports_datetime_with_precision?

        add_column table_name, :created_at, :datetime, **options
        add_column table_name, :updated_at, 'DATETIME ON UPDATE CURRENT_TIMESTAMP', **options
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    # Overrides the `timestamps` method in `TableDefinition` to use MySQL's `DATETIME ON UPDATE CURRENT_TIMESTAMP`
    # for the `updated_at` column.
    # This allows the `updated_at` column to automatically update its value whenever the row is updated.
    class TableDefinition
      def timestamps(**options)
        options[:null] = false if options[:null].nil?

        options[:precision] = 6 if !options.key?(:precision) && @conn.supports_datetime_with_precision?

        column(:created_at, :datetime, **options)
        column(:updated_at, 'DATETIME ON UPDATE CURRENT_TIMESTAMP', **options)
      end
    end
  end
end
