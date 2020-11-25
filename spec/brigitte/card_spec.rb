# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brigitte::Card, type: :model do
  let(:ace_card_club_suit) { described_class.new('A', '♣') }

  describe '#initialize' do
    it 'sets id' do
      card = described_class.new('2', '♣')
      expect(card.id).not_to be_nil
      expect(card.id).not_to eq ''
    end
  end
  describe '#to_s' do
    it 'merges value with sign as a string' do
      expect(ace_card_club_suit.to_s).to eq 'A♣'
    end
  end
  describe '==' do
    context 'same card different id' do
      let(:ace_card_club_suit2) { described_class.new('A', '♣') }
      it 'is not equal' do
        expect(ace_card_club_suit == ace_card_club_suit2).to be_falsey
      end
    end
    context 'same id' do
      let(:ace_card_club_suit2) { ace_card_club_suit.dup }
      it 'is equal' do
        expect(ace_card_club_suit == ace_card_club_suit2).to be_truthy
      end
    end
  end
  describe '#weight' do
    { '2' => 2,
      '3' => 3,
      '4' => 4,
      '5' => 5,
      '6' => 6,
      '7' => 7,
      '8' => 8,
      '9' => 9,
      '10' => 10,
      'J' => 11,
      'Q' => 12,
      'K' => 13,
      'A' => 14 }.each do |value, weight|
      it "card with value #{value} has a weight of #{weight}" do
        expect(described_class.new(value, '♣').weight).to eq weight
      end
    end
  end
end
