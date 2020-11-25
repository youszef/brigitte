# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brigitte::Deck, type: :model do
  describe '#initialize' do
    it 'initiates card correctly' do
      card = described_class.new.cards.first
      expect(described_class::PREFIX.include?(card.value)).to be_truthy
      expect(described_class::SIGNS.include?(card.sign)).to be_truthy
    end
    it 'sets 52 unique cards' do
      expect(described_class.new.cards.uniq.count).to eq 52
    end
    it 'shuffles cards' do
      deck1 = described_class.new
      deck2 = described_class.new
      expect(deck1.cards.map(&:to_s)).not_to eq deck2.cards.map(&:to_s)
    end
  end
end
