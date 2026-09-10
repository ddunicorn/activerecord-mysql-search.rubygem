# frozen_string_literal: true

RSpec.describe MySQL::Search::Queries::BooleanFullTextSearchQuery do
  subject(:query) { described_class.new(source_relation) }

  let(:source_relation) { Article.all }

  describe '#call' do
    it 'joins the search index and uses boolean full-text mode', :aggregate_failures do
      sql = query.call('+test -draft').to_sql

      expect(sql).to include('INNER JOIN `search_indices`')
      expect(sql).to include("AGAINST ('+test -draft' IN BOOLEAN MODE)")
    end

    it 'supports searching across multiple columns' do
      sql = query.call('+test -draft', search_column: %i[content title]).to_sql

      expect(sql).to include(
        "MATCH(`search_indices`.`content`, `search_indices`.`title`) AGAINST ('+test -draft' IN BOOLEAN MODE)"
      )
    end
  end
end
