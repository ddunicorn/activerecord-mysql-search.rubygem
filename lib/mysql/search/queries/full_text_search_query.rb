# frozen_string_literal: true

require 'arel'

module Arel
  module Visitors
    # Custom visitor for MySQL to handle the `AGAINST` clause in full-text search.
    class MySQL
      def visit_Arel_Nodes_Against(node, collector) # rubocop:disable Naming/MethodName
        visit(node.left, collector) << ' AGAINST ('
        visit(node.right, collector) << ')'
      end
    end
  end
end

module Arel
  module Nodes
    # Represents the `AGAINST` clause used in MySQL full-text search queries.
    class Against < Arel::Nodes::Matches
    end
  end
end

module Arel
  # Adds a method to the `Arel::Nodes::Node` class to allow for full-text search queries.
  module Predications
    def against(other)
      Arel::Nodes::Against.new(self, quoted_node(other))
    end
  end
end

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
          search_term = ::MySQL::Search::Utils::TextNormalizer.normalize(search_term)
          search_indices = ::MySQL::Search.search_index_class_name.constantize.arel_table
          search_columns = Array.wrap(search_column).map { |col| search_indices[col] }

          Arel::Nodes::NamedFunction.new('MATCH', search_columns).against(search_term)
        end
      end
    end
  end
end
