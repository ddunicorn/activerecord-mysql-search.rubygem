# frozen_string_literal: true

class NewsDigest < ApplicationRecord
  include MySQL::Search::Searchable
end
