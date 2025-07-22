# frozen_string_literal: true

RSpec.describe MySQL::Search::Source do
  subject(:source) { described_class.new(model) }

  let(:model) do
    Class.new do
      def text_attribute = 'text'
      def date_attribute = Date.new(2020, 1, 1)
      def calendar_week_attribute = Date.new(2020, 10, 1)

      def association
        self
      end
    end.new
  end

  let(:config) do
    {
      content: { text_attribute: :text, association: { date_attribute: :date } }
    }
  end

  describe '#extract' do
    before { source._config = config }

    it 'extracts data from model' do
      expect(source.extract).to eq(content: 'text 01.01.2020')
    end
  end
end
