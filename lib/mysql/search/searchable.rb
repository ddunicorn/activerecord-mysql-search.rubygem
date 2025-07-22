# frozen_string_literal: true

module MySQL
  module Search
    # Provides ActiveRecord integration for search indexing.
    module Searchable
      extend ActiveSupport::Concern

      included do
        has_one :search_index, class_name: ::MySQL::Search.search_index_class_name.to_s,
                               as: :searchable,
                               dependent: :destroy

        scope :full_text_search_sources_updated, lambda { |time_ago|
          ::MySQL::Search::Queries::UpdatedSourcesQuery.new(self).call(time_ago)
        }

        scope :full_text_search, lambda { |search_term, search_column: :content|
          ::MySQL::Search::Queries::FullTextSearchQuery.new(self).call(search_term, search_column: search_column)
        }
      end
    end
  end
end
