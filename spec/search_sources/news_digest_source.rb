# frozen_string_literal: true

class NewsDigestSource < MySQL::Search::Source
  schema content: { title: :text,
                    summary: :text,
                    published_at: %i[date calendar_week] }
end
