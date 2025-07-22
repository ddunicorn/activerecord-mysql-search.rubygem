# frozen_string_literal: true

module MySQL
  module Search
    # Extracts and formats data for search indexing.
    class Grabber
      attr_reader :model, :config

      def initialize(model, config)
        @model = model
        @config = config
      end

      def grab
        config.flat_map do |attr_or_relation, format_or_config|
          case format_or_config
          when Hash then forward(attr_or_relation, format_or_config)
          when Symbol, String, Array, Proc then format(attr_or_relation, format_or_config)
          else
            raise(ArgumentError, "unknown config value: '#{format_or_config.inspect}'")
          end
        end
      end

      private

      def forward(relation_name, grab_config)
        relation = model.public_send(relation_name)

        if relation.is_a?(::ActiveRecord::Relation)
          relation.flat_map { |model| Grabber.new(model, grab_config).grab }
        else
          Grabber.new(relation, grab_config).grab
        end
      end

      def format(attr_or_relation, formatters)
        return [] if model.nil?

        unless model.respond_to?(attr_or_relation)
          raise ArgumentError,
                "Missing attribute or relation `#{attr_or_relation}` on the model `#{model.class}`"
        end

        value = model.public_send(attr_or_relation)

        Array.wrap(formatters).map { |formatter| Utils::Formatter.new(value, formatter).format }
      end
    end
  end
end
