# frozen_string_literal: true

module MySQL
  module Search
    module Queries
      # Queries updated sources for search indexing.
      class UpdatedSourcesQuery
        attr_reader :source_relation, :source_class_name

        def initialize(source_relation)
          @source_relation = source_relation.all
          @source_class_name = "#{source_relation.all.klass.name}Source"
        end

        def call(time_ago)
          joins_args = source_class_name.constantize.joins_args
          relation = source_relation.left_joins(joins_args).where(updated_at: time_ago..)

          append_conditions(relation, source_relation, joins_args, time_ago)
        end

        private

        def append_conditions(relation, root_class, config, time_ago)
          case config
          when Array then config.reduce(relation) { |rel, item| append_conditions(rel, root_class, item, time_ago) }
          when Hash
            relation = append_conditions(relation, root_class, config.keys, time_ago)

            config.reduce(relation) do |rel, (root_association, nested_config)|
              append_conditions(rel, association_class(root_class, root_association), nested_config, time_ago)
            end
          else
            append_or(relation, association_class(root_class, config), time_ago)
          end
        end

        def association_class(root_class, association)
          root_class.reflect_on_association(association).klass
        end

        def append_or(relation, model, time_ago)
          return relation unless model.column_names.include?('updated_at')

          relation.or(model.where(updated_at: time_ago..))
        end
      end
    end
  end
end
