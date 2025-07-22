# frozen_string_literal: true

RSpec.describe MySQL::Search::Queries::UpdatedSourcesQuery do
  subject(:query) { described_class.new(Article) }

  describe '#call' do
    it 'generates a query that joins sources joined' do
      sql = query.call(1.day.ago).to_sql

      expect(sql).to match(/LEFT OUTER JOIN `news_digests`/)
    end

    it 'generates a query that adds sources updated_at condition' do
      sql = query.call(1.day.ago).to_sql

      expect(sql).to match(/`articles`.`updated_at` >= '.+' OR `news_digests`.`updated_at` >= '.+'/)
    end
  end
end
