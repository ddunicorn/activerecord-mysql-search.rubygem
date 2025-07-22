# frozen_string_literal: true

# Represents an article model that is searchable within a news digest context.
class Article < ApplicationRecord
  include MySQL::Search::Searchable

  belongs_to :news_digest
end
