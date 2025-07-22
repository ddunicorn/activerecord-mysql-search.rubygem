# frozen_string_literal: true

RSpec.describe MySQL::Search::Callbacks do
  subject(:callbacks) { described_class.new(source_model_class, source_config) }

  let(:source_association_class) do
    Class.new do
      def self.after_save(&); end
    end
  end

  let(:source_model_class) do
    Class.new do
      def self.after_save(&); end
      def self.reflect_on_association(association); end
    end
  end

  let(:reflection) do
    Class.new do
      def self.klass; end
    end
  end

  let(:source_config) do
    {
      general: { association: { assoc_attr: :text }, gen_attr: :text },
      customer: { cus_attr: %i[text date] },
      internal_employee: { ie_attr: :calendar_week }
    }
  end

  describe '#initialize' do
    it 'transforms source config to callbacks config' do
      expect(callbacks.callbacks_config).to eq(
        [:association] => [:assoc_attr],
        [] => %i[gen_attr cus_attr ie_attr]
      )
    end
  end

  describe '#assign' do
    before do
      allow(source_model_class).to receive(:reflect_on_association).and_return(reflection)
      allow(reflection).to receive(:klass).and_return(source_association_class)

      allow(source_model_class).to receive(:after_save)
      allow(source_association_class).to receive(:after_save)
    end

    it 'assigns callbacks to source model class' do
      callbacks.assign

      expect(source_model_class).to have_received(:after_save)
    end

    it 'assigns callbacks to source association class' do
      callbacks.assign

      expect(source_association_class).to have_received(:after_save)
    end

    it 'is idempotent for source model' do
      callbacks.assign
      callbacks.assign

      expect(source_model_class).to have_received(:after_save).once
    end

    it 'is idempotent for source association model' do
      callbacks.assign
      callbacks.assign

      expect(source_association_class).to have_received(:after_save).once
    end
  end

  describe '.callback' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:source_model_class_name) { 'SourceModelClassName' }
    let(:associated) { instance_double(ActiveRecord::Base, id: 1) }
    let(:association_path) { [:association] }
    let(:on_attributes_change) { [:attr] }

    let(:automatic_update) { true }
    let(:saved_change_to_attribute) { true }
    let(:update_asyncronously) { true }

    let(:configured_job) { instance_double(ActiveJob::ConfiguredJob, perform_now: nil, perform_later: nil) }

    before do
      allow(MySQL::Search).to receive_messages(automatic_update: automatic_update,
                                               update_asyncronously: update_asyncronously)
      allow(associated).to receive(:saved_change_to_attribute?).and_return(saved_change_to_attribute)

      allow(MySQL::Search::Jobs::UpdaterJob).to receive(:set).and_return(configured_job)

      described_class.callback(source_model_class_name, associated, association_path, on_attributes_change)
    end

    context 'when automatic update is disabled' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:automatic_update) { false }

      it 'does not perform update' do
        expect(configured_job).not_to have_received(:perform_later)
      end
    end

    context 'when no changes in attributes' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:saved_change_to_attribute) { false }

      it 'does not perform update' do
        expect(configured_job).not_to have_received(:perform_later)
      end
    end

    context 'when update asyncronously is disabled' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:update_asyncronously) { false }

      it 'performs update now' do
        expect(configured_job).to have_received(:perform_now)
      end

      it 'does not perform update later' do
        expect(configured_job).not_to have_received(:perform_later)
      end
    end

    it 'performs update later' do
      expect(configured_job).to have_received(:perform_later)
    end

    it 'does not perform update now' do
      expect(configured_job).not_to have_received(:perform_now)
    end
  end
end
