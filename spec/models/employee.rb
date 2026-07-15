# frozen_string_literal: true

class Employee < ApplicationRecord
  include MySQL::Search::Searchable

  belongs_to :author
end
