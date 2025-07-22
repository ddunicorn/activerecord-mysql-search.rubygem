# frozen_string_literal: true

module MySQL
  module Search
    # Represents a source for search indexing.
    class Source
      class_attribute :_model
      class_attribute :_config, default: {}
      class_attribute :_callbacks

      attr_reader :model

      def self.schema(config)
        self._model = model
        self._config = _config.merge(config)
        self._callbacks = ::MySQL::Search::Callbacks.new(_model, _config)

        _callbacks.assign
      end

      def self.model
        _model || name.delete_suffix('Source').constantize
      end

      def self.joins_args
        combined_config = _config.values.reduce(&:deep_merge)
        extract_joins_args(combined_config)
      end

      def initialize(model)
        @model = model
      end

      def extract
        _config.each_with_object({}) do |(search_index_attribute, grabber_config), extracted|
          validate_search_index_attribute!(search_index_attribute)

          grabbed_data = Grabber.new(model, grabber_config).grab
          extracted[search_index_attribute] = grabbed_data.compact.join(' ').squish
        end
      end

      def self.extract_joins_args(config)
        config.each_with_object([]) do |(attr_or_relation, format_or_config), extracted|
          next unless format_or_config.is_a?(Hash)

          extracted << if format_or_config.values.any?(Hash)
                         { attr_or_relation => extract_joins_args(format_or_config) }
                       else
                         attr_or_relation
                       end
        end
      end

      private_class_method :extract_joins_args

      private

      def validate_search_index_attribute!(search_index_attribute)
        return if Search.search_index_class.column_names.include?(search_index_attribute.to_s)

        raise(
          ArgumentError,
          "Unknown attribute '#{search_index_attribute}' for #{::MySQL::Search.search_index_class.name}"
        )
      end
    end
  end
end
