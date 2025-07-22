# frozen_string_literal: true

# This migration creates a search index table for MySQL full-text search.
class CreateSearchIndices < ActiveRecord::Migration[7.0]
  create_table :search_indices do |t|
    t.text :content, null: false
    t.references :searchable, polymorphic: true, null: false

    t.index :content, type: :fulltext
  end
end
