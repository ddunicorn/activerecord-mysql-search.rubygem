# frozen_string_literal: true

module MySQL
  module Search
    module Utils
      # Formats values for search indexing.
      class Formatter
        attr_reader :value, :formatter

        def initialize(value, formatter)
          if formatter.instance_of?(Proc)
            @value = formatter.call(value)
            @formatter = nil
          elsif respond_to?(formatter, true)
            @value = value
            @formatter = formatter
          else
            raise(ArgumentError, "Unknown formatter name: '#{formatter.inspect}'")
          end
        end

        def format
          formatter ? send(formatter) : value
        end

        private

        def text
          TextNormalizer.normalize(value.to_s)
        end

        def calendar_week
          value&.strftime(::MySQL::Search.calendar_week_format)
        end

        def date
          value&.strftime(::MySQL::Search.date_format)
        end
      end
    end
  end
end
