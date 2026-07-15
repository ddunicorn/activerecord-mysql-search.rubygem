# frozen_string_literal: true

class ExternalEmployeeSource < MySQL::Search::Source
  schema content: {
    author: {
      name: :text
    }
  }
end
