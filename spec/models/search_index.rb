# frozen_string_literal: true

# Model that stores search indices for various models.
class SearchIndex < ApplicationRecord
  belongs_to :searchable, polymorphic: true
end
