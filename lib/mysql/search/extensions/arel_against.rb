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

  module Nodes
    # Represents the `AGAINST` clause used in MySQL full-text search queries.
    class Against < Arel::Nodes::Matches
    end
  end

  # Adds a method to the `Arel::Nodes::Node` class to allow for full-text search queries.
  module Predications
    def against(other)
      Arel::Nodes::Against.new(self, quoted_node(other))
    end
  end
end
