# frozen_string_literal: true

RSpec.describe MySQL::Search::Queries::UpdatedSourcesQuery do
  subject(:query) { described_class.new(source_relation) }

  let(:source_relation) { Article }

  describe '#call' do
    it 'generates a query that joins sources joined' do
      sql = query.call(1.day.ago).to_sql

      expect(sql).to include('LEFT OUTER JOIN `news_digests`')
    end

    it 'generates a query that adds sources updated_at condition' do
      sql = query.call(1.day.ago).to_sql

      expect(sql).to match(/`articles`.`updated_at` >= '.+' OR `news_digests`.`updated_at` >= '.+'/)
    end

    context 'when source relation uses STI subclass with associated source updates' do
      let(:source_relation) { ExternalEmployee }
      let(:author) { Author.create!(name: 'Author') }
      let(:internal_employee) { InternalEmployee.create!(author: author) }
      let(:external_employee) { ExternalEmployee.create!(author: author) }

      before do
        external_employee
        internal_employee.touch(time: 2.days.ago) # rubocop:disable Rails/SkipsModelValidations
        author.touch # rubocop:disable Rails/SkipsModelValidations
      end

      it 'keeps STI scope while appending OR association conditions' do
        expect { query.call(1.day.ago).to_a }.not_to raise_error
      end
    end
  end
end
