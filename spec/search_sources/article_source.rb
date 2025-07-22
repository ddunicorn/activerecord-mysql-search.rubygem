# frozen_string_literal: true

class ArticleSource < MySQL::Search::Source
  schema content: { title: :text,
                    content: :text,
                    news_digest: { title: :text, published_at: %i[date calendar_week] } }
end
