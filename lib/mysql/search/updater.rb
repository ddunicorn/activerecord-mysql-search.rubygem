# frozen_string_literal: true

module MySQL
  module Search
    # Updates search indices based on associated models.
    class Updater
      attr_reader :full_text_searchable,
                  :associated_model,
                  :joins_args,
                  :source_class

      def initialize(full_text_searchable:, associated_model:, association_path: [])
        @full_text_searchable = full_text_searchable
        @associated_model = associated_model
        @joins_args = translate_to_joins_args(association_path)
        @source_class = "#{full_text_searchable.name}Source".constantize
      end

      def update
        full_text_searchable.transaction do
          full_text_searchables.find_each do |model|
            search_index = model.search_index || model.build_search_index

            search_index.update(source_class.new(model).extract)
          end
        end
      end

      private

      def translate_to_joins_args(association_path)
        return association_path if association_path.empty? || association_path.one?

        target_association = association_path.pop

        association_path.reverse.inject(target_association) { |memo, association| { association => memo } }
      end

      def full_text_searchables
        associated_model_relation = associated_model.class.where(id: associated_model.id)

        full_text_searchable.joins(joins_args).preload(:search_index).merge(associated_model_relation)
      end
    end
  end
end
