# frozen_string_literal: true

RSpec.describe MySQL::Search::Updater do
  subject(:updater) do
    described_class.new(
      full_text_searchable: full_text_searchable,
      associated_model: associated_model,
      association_path: association_path
    )
  end

  let(:full_text_searchable) { article.class }
  let(:associated_model) { news_digest }
  let(:association_path) { [:news_digest] }

  let!(:news_digest) { NewsDigest.create!(title: 'NewsTitle', summary: 'With some summary') }
  let!(:article) { Article.create!(title: 'ArticleTitle', content: 'With some content', news_digest:) }

  describe '#initialize' do
    context 'when the association_path is empty' do
      let(:association_path) { [] }

      it 'sets the joins_args' do
        expect(updater.joins_args).to eq []
      end
    end

    context 'when the association_path exists' do
      let(:association_path) { %i[news_digest] }

      it 'sets the joins_args' do
        expect(updater.joins_args).to eq([:news_digest])
      end
    end
  end

  describe '#update' do
    it 'creates the search_index' do
      updater.update

      expect(article.search_index).to be_persisted
    end

    it 'saves the extracted data' do
      updater.update

      expect(article.search_index.attributes).to include(
        'content' => an_instance_of(String)
      )
    end
  end
end
