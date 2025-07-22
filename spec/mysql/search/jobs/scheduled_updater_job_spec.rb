# frozen_string_literal: true

RSpec.describe MySQL::Search::Jobs::ScheduledUpdaterJob do
  subject(:job) { described_class.new }

  let(:news_digest) { NewsDigest.create!(title: 'Test Digest', summary: 'Test Summary') }

  describe 'PERIODS' do
    let(:sql) { described_class::PERIODS[period].call(NewsDigest).to_sql }

    it 'contains the correct periods' do
      expect(described_class::PERIODS.keys).to contain_exactly('daily', 'weekly', 'monthly', 'all')
    end

    context 'when period is daily' do
      let(:period) { :daily }

      it { expect(sql).to include('`news_digests`.`updated_at` >=') }
      it { expect(sql).to include(Date.yesterday.to_s) }
    end

    context 'when period is weekly' do
      let(:period) { :weekly }

      it { expect(sql).to include('`news_digests`.`updated_at` >=') }
      it { expect(sql).to include(1.week.ago.to_date.to_s) }
    end

    context 'when period is monthly' do
      let(:period) { :monthly }

      it { expect(sql).to include('`news_digests`.`updated_at` >=') }
      it { expect(sql).to include(1.month.ago.to_date.to_s) }
    end

    context 'when period is all' do
      let(:period) { :all }

      it { expect(sql).not_to include('`news_digests`.`updated_at` >=') }
      it { expect(sql).not_to include('WHERE') }
    end
  end

  describe '#perform', :disable_automatic_update do
    context 'when full text search does not exist' do
      it 'creates the full text search index' do
        expect { job.perform(:all) }.to change { news_digest.reload.search_index }
          .from(nil)
          .to(an_instance_of(SearchIndex))
      end
    end

    context 'when full text search exists' do
      before { news_digest.create_search_index(content: 'previous text') }

      it 'updates the full text search index' do
        expect { job.perform(:all) }.to change {
          news_digest.search_index.reload.content
        }.from('previous text').to('Test Digest Test Summary')
      end
    end
  end
end
