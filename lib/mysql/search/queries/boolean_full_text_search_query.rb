# frozen_string_literal: true

require_relative 'full_text_search_query'

module MySQL
  module Search
    module Queries
      # BooleanFullTextSearchQuery builds MySQL boolean full-text search queries.
      class BooleanFullTextSearchQuery < FullTextSearchQuery
        private

        def search_expression(search_term, search_column)
          search_indices = ::MySQL::Search.search_index_class_name.constantize.arel_table
          search_columns = Array.wrap(search_column).map { |col| search_indices[col] }

          Arel::Nodes::NamedFunction.new('MATCH', search_columns).against(search_term, boolean_mode: true)
        end
      end
    end
  end
end
