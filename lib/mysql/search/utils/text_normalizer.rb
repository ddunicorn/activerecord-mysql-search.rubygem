# frozen_string_literal: true

module MySQL
  module Search
    module Utils
      # Normalizes text by removing non-alphanumeric characters, except for spaces and hyphens.
      class TextNormalizer
        REGEXP = /[[:alnum:][:blank:]+\-*~<>()"@\.]/

        def self.normalize(value)
          value.to_s.scan(REGEXP).join.squish
        end
      end
    end
  end
end
