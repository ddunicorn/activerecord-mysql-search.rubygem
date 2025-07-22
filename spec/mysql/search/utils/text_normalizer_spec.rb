# frozen_string_literal: true

RSpec.describe MySQL::Search::Utils::TextNormalizer do
  subject(:normalized) { described_class.normalize(value) }

  describe '.normalize' do
    let(:value) { 'Hello, World! This is a test: 1234!.' }

    it 'filterings returning correct result' do
      expect(normalized).to eq('Hello World This is a test 1234.')
    end
  end
end
