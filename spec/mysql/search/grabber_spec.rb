# frozen_string_literal: true

RSpec.describe MySQL::Search::Grabber do
  describe '#grab' do
    subject(:grabber) { described_class.new(article, config).grab }

    let(:article) { Article.create!(title: 'ArticleTitle', content: 'With some content', news_digest:) }
    let(:news_digest) do
      NewsDigest.create!(title: 'NewsTitle', summary: 'With some summary', published_at: Date.parse('2025-10-11'))
    end

    context 'when hash config' do
      let(:config) { { news_digest: { title: :text } } }

      it 'returns correct relation text' do
        expect(grabber).to eq(['NewsTitle'])
      end
    end

    context 'when symbol config' do
      let(:config) { { news_digest: { published_at: :date } } }

      it 'returns correct symbol' do
        expect(grabber).to eq(['11.10.2025'])
      end
    end

    context 'when string config' do
      let(:config) { { content: 'text' } }

      it 'returns correct text' do
        expect(grabber).to eq(['With some content'])
      end
    end

    context 'when array config' do
      let(:config) { { news_digest: { published_at: %i[calendar_week date] } } }

      it 'returns correct array' do
        expect(grabber).to contain_exactly('11.10.2025', 'week 41')
      end
    end

    context 'when incorrect config value is passed' do
      let(:config) { { news_digest: { title: 1234 } } }

      it 'raises in error' do
        expect { grabber }.to raise_error(ArgumentError)
      end
    end
  end
end
