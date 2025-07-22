# frozen_string_literal: true

RSpec.describe MySQL::Search do
  describe 'configuration' do
    it { is_expected.to respond_to(:automatic_update) }
    it { is_expected.to respond_to(:update_asyncronously) }
    it { is_expected.to respond_to(:search_index_class_name) }
    it { is_expected.to respond_to(:sources_path) }
    it { is_expected.to respond_to(:configure) }
  end

  describe 'integration' do
    let(:news_digest) do
      NewsDigest.create!(title: 'Test Digest', summary: 'Summary', published_at: '2025-06-01')
    end

    let(:article) do
      Article.create!(title: 'Test Article', content: 'Content', news_digest: news_digest)
    end

    it 'creates corresponding search index record of News Digest' do
      expect { news_digest }.to change(SearchIndex, :count).by(1)
    end

    it 'contains correct search index content of News Digest' do
      content = news_digest.search_index.content

      expect(content).to eq('Test Digest Summary 01.06.2025 week 22')
    end

    it 'creates corresponding search index record of Article and News Digest' do
      expect { article }.to change(SearchIndex, :count).by(2)
    end

    it 'contains correct search index content of Article' do
      content = article.search_index.content

      expect(content).to eq('Test Article Content Test Digest 01.06.2025 week 22')
    end

    it 'finds corresponding News Digest by full text search' do
      results = NewsDigest.full_text_search(news_digest.title)

      expect(results).to include(news_digest)
    end
  end
end
