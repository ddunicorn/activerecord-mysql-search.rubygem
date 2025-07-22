# frozen_string_literal: true

module MySQL
  module Search
    # Manages callbacks for updating search indices.
    class Callbacks
      attr_reader :source_model_class, :callbacks_config, :assigned

      def self.callback(source_model_class_name, associated, association_path, on_attributes_change)
        return unless enqueue_update?(associated, on_attributes_change)

        perform = ::MySQL::Search.update_asyncronously ? :perform_later : :perform_now

        ::MySQL::Search::Jobs::UpdaterJob.set(wait: 10.seconds).public_send(
          perform,
          source_model_class_name,
          associated.class.name,
          associated.id,
          association_path
        )
      end

      def self.enqueue_update?(associated, on_attributes_change)
        return false unless ::MySQL::Search.automatic_update

        on_attributes_change.any? { |attribute| associated.saved_change_to_attribute?(attribute) }
      end

      def initialize(source_model_class, source_config)
        @source_model_class = source_model_class
        @callbacks_config = transform_source_config(source_config)
        @assigned = false
      end

      def assign
        return if @assigned

        callbacks_config.each do |association_path, on_attributes_change|
          source_model_class_name = source_model_class.name
          associated_class(association_path).after_save do
            ::MySQL::Search::Callbacks.callback(source_model_class_name, self, association_path, on_attributes_change)
          end
        end

        @assigned = true
      end

      private

      def transform_source_config(source_config)
        extract_association_paths(config: source_config.values.reduce(&:deep_merge))
      end

      def extract_association_paths(config:, association_config: {}, association_path: [])
        config.each do |attribute_or_relation, attribute_or_relation_config|
          if attribute_or_relation_config.is_a?(Hash)
            extract_association_paths(association_config: association_config,
                                      association_path: [*association_path, attribute_or_relation],
                                      config: attribute_or_relation_config)
          else
            association_config[association_path] = [*association_config[association_path], attribute_or_relation]
          end
        end

        association_config
      end

      def associated_class(association_path)
        association_path.inject(source_model_class) do |memo, association|
          memo.reflect_on_association(association).klass
        end
      end
    end
  end
end
