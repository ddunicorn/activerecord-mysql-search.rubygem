# frozen_string_literal: true

module MySQL
  module Search
    module Utils
      # Formats values for search indexing.
      class Formatter
        attr_reader :value, :formatter

        def self.register(name, &block)
          define_method(name) do
            block.call(value)
          end
        end

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
          (formatter ? send(formatter) : value).to_s.strip
        end

        private

        def text
          value
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
