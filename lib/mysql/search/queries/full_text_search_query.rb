# frozen_string_literal: true

require_relative '../extensions/arel_against'

module MySQL
  module Search
    module Queries
      # FullTextSearchQuery is responsible for building and executing full-text search queries
      class FullTextSearchQuery
        attr_reader :source_relation

        def initialize(source_relation)
          @source_relation = source_relation
        end

        def call(search_term, search_column: :content)
          relation_table = source_relation.klass.arel_table

          search_expression = search_expression(search_term, search_column)

          [relation_table[Arel.star], search_expression.as('search_term_relevancy')]

          source_relation
            # .select(*select_expression)
            .joins(:search_index)
            .where(search_expression)
            .order(search_expression.desc)
        end

        private

        def search_expression(search_term, search_column)
          search_indices = ::MySQL::Search.search_index_class_name.constantize.arel_table
          search_columns = Array.wrap(search_column).map { |col| search_indices[col] }

          Arel::Nodes::NamedFunction.new('MATCH', search_columns).against(search_term)
        end
      end
    end
  end
end
