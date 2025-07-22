# frozen_string_literal: true

RSpec.describe MySQL::Search::Searchable do
  subject(:model) { Article }

  it { expect(model.new).to respond_to(:search_index) }

  describe 'scopes' do
    describe '.full_text_search_sources_updated' do
      it { expect(model.full_text_search_sources_updated(1.day.ago).to_a).to be_an_instance_of(Array) }
    end

    describe '.full_text_search' do
      it { expect(model.full_text_search('test').to_a).to be_an_instance_of(Array) }
    end
  end
end
