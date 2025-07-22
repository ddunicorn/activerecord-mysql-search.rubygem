# frozen_string_literal: true

RSpec.describe MySQL::Search::Jobs::UpdaterJob do
  subject(:job) { described_class.new }

  let(:full_text_searchable) { Article }
  let(:associated) { NewsDigest.create!(title: 'Digest', summary: 'Summary') }
  let(:association_path) { [:news_digest] }
  let(:updater) { instance_double(MySQL::Search::Updater, update: nil) }

  before do
    allow(NewsDigest).to receive(:find).and_return(associated)
    allow(MySQL::Search::Updater).to receive(:new).and_return(updater)

    job.perform(full_text_searchable.name, associated.class.name, associated.id, association_path)
  end

  describe '#perform' do
    context 'when record exists' do
      it 'triggers updater' do
        expect(MySQL::Search::Updater).to have_received(:new).with(
          full_text_searchable: full_text_searchable,
          associated_model: associated,
          association_path: association_path
        )
      end
    end

    context 'when record does not exist' do
      let(:associated) { NewsDigest.new(title: 'Digest 2') }

      it 'does not trigger updater' do
        expect(MySQL::Search::Updater).not_to have_received(:new)
      end
    end
  end
end
