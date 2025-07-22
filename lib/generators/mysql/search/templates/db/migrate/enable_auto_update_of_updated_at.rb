# frozen_string_literal: true

# This migration enables automatic updates for `updated_at` columns in all tables that have this column.
# It changes the column type to `DATETIME ON UPDATE CURRENT_TIMESTAMP`, which allows MySQL to automatically update
# the `updated_at` timestamp whenever the row is updated.
class EnableAutoUpdateForUpdatedAtColumns < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.connection.tables.each do |table_name|
      next unless column_exists?(table_name, :updated_at)

      change_column table_name, :updated_at, 'DATETIME ON UPDATE CURRENT_TIMESTAMP'
    end
  end

  def down
    ActiveRecord::Base.connection.tables.each do |table_name|
      next unless column_exists?(table_name, :updated_at)

      change_column table_name, :updated_at, :datetime
    end
  end
end
