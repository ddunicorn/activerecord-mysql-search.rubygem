# frozen_string_literal: true

RSpec.describe MySQL::Search::Queries::FullTextSearchQuery do
  subject(:query) { described_class.new(source_relation) }

  let(:source_relation) { Article.all }

  describe '#call' do
    it 'joins the search index and uses natural-language full-text mode', :aggregate_failures do
      sql = query.call('test draft').to_sql

      expect(sql).to include('INNER JOIN `search_indices`')
      expect(sql).to include("AGAINST ('test draft')")
      expect(sql).not_to include('IN BOOLEAN MODE')
    end

    it 'supports searching across multiple columns' do
      sql = query.call('test draft', search_column: %i[content title]).to_sql

      expect(sql).to include(
        "MATCH(`search_indices`.`content`, `search_indices`.`title`) AGAINST ('test draft')"
      )
    end
  end
end
