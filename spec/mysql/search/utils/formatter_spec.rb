# frozen_string_literal: true

RSpec.describe MySQL::Search::Utils::Formatter do
  subject(:formatter) { described_class.new(value, format_name) }

  let(:value) { 'Test String $ with Special Symbols!' }
  let(:format_name) { :wrong }

  context 'when incorrect format name is passed' do
    it 'raises in error' do
      expect { formatter }.to raise_error(ArgumentError)
    end
  end

  describe '#format' do
    subject(:formatted_value) { formatter.format }

    context 'when required format is :text' do
      let(:format_name) { :text }

      it { is_expected.to eq('Test String $ with Special Symbols!') }
    end

    context 'when required format is :calendar_week' do
      let(:format_name) { :calendar_week }
      let(:value) { Date.parse('2020-01-01') }

      it { is_expected.to eq('week 01') }
    end

    context 'when required format is :date' do
      let(:value) { Date.parse('2020-01-01') }
      let(:format_name) { :date }

      it 'returns datetime as date' do
        expect(formatter.format).to eq('01.01.2020')
      end
    end
  end

  describe '.register' do
    before do
      described_class.register(:custom_format) do |val|
        val.to_s.upcase
      end
    end

    let(:format_name) { :custom_format }

    it 'registers a new format method' do
      expect(formatter.format).to eq('TEST STRING $ WITH SPECIAL SYMBOLS!')
    end
  end
end
