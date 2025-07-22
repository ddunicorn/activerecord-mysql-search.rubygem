# frozen_string_literal: true

module MySQL
  module Search
    module Utils
      # Parses duration strings into ActiveSupport::Duration objects.
      class DurationParser
        REGEXP = /(\d+)[.\s](year|month|week|day|hour|minute|second)s?/

        def self.parse(duration_string, default = nil)
          match_data = duration_string.to_s.match(REGEXP)

          return default if match_data.nil?

          match_data[1].to_i.public_send(match_data[2])
        end
      end
    end
  end
end
