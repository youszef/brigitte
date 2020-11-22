# frozen_string_literal: true

require 'spec_helper'


RSpec.describe Brigitte::Commands::Pot::AddCards do
  let(:cards) { [] }

  describe '#process' do
    let(:player) do
                   player = Brigitte::Player.new('test_player')
                   player.hand = cards
                   player
    end

    context 'when player throws card not in hand' do
      let(:pot) { [] }

      before do
        player.hand.clear
      end

      it 'returns false' do
        cards = [Brigitte::Card.new('A', '♣')]
        player.hand = [Brigitte::Card.new('3', '♣')]
        expect(described_class.process(player, cards, pot)).to be_falsey
      end

      it 'does not throw card' do
        cards = [Brigitte::Card.new('A', '♣')]
        player.hand = [Brigitte::Card.new('3', '♣')]
        described_class.process(player, cards, pot)
        expect(pot).to be_empty
        expect(player.hand.count).to eq 1
      end
    end
    context 'when pot empty' do
      let(:pot) { [] }

      it 'adds single card to pot' do
        cards.push(Brigitte::Card.new('A', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'adds multiple same cards to pot' do
        cards.push(Brigitte::Card.new('A', '♣'))
        cards.push(Brigitte::Card.new('A', '♦'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'adds 4 same cards to pot and empties it' do
        cards.push(Brigitte::Card.new('A', '♣'))
        cards.push(Brigitte::Card.new('A', '♦'))
        cards.push(Brigitte::Card.new('A', '♥'))
        cards.push(Brigitte::Card.new('A', '♠'))
        described_class.process(player, cards, pot)
        expect(pot).to be_empty
      end

      it 'does not add multiple different cards to pot' do
        cards.push(Brigitte::Card.new('A', '♣'))
        cards.push(Brigitte::Card.new('K', '♣'))
        described_class.process(player, cards, pot)
        expect(pot).to be_empty
      end
    end
    context 'when last card on pot is 3' do
      let(:pot) { [Brigitte::Card.new('3', '♣')] }

      it 'adds single card which is higher than last card on pot' do
        cards.push(Brigitte::Card.new('4', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'adds same card to pot' do
        cards.push(Brigitte::Card.new('3', '♦'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'adds card 2 to pot' do
        cards.push(Brigitte::Card.new('2', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'adds 3 cards with value 3 to pot and empties it' do
        cards.push(Brigitte::Card.new('3', '♦'))
        cards.push(Brigitte::Card.new('3', '♥'))
        cards.push(Brigitte::Card.new('3', '♠'))
        described_class.process(player, cards, pot)
        expect(pot).to be_empty
      end
    end
    context 'when last card on pot is 4' do
      let(:pot) { [Brigitte::Card.new('4', '♣')] }

      it 'adds single card which is higher than last card on pot' do
        cards.push(Brigitte::Card.new('5', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'does not add card that is lower than last card on pot' do
        cards.push(Brigitte::Card.new('3', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_falsey
      end
    end
    context 'when last card on pot is 7' do
      let(:pot) { [Brigitte::Card.new('7', '♣')] }

      it 'adds single card which is lower than last card on pot' do
        cards.push(Brigitte::Card.new('5', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'does not add card that is higher than last card on pot' do
        cards.push(Brigitte::Card.new('8', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_falsey
      end

      it 'adds same card to pot' do
        cards.push(Brigitte::Card.new('7', '♦'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'adds card 2 to pot' do
        cards.push(Brigitte::Card.new('2', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end
    end
    context 'when last card on pot is Ace' do
      let(:pot) { [Brigitte::Card.new('A', '♣')] }

      it 'adds card 2 to pot' do
        cards.push(Brigitte::Card.new('2', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'adds same card to pot' do
        cards.push(Brigitte::Card.new('A', '♦'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end

      it 'does not add card that is lower than last card on pot' do
        cards.push(Brigitte::Card.new('K', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_falsey
      end
    end
    context 'when last card on pot is 2' do
      let(:pot) { [Brigitte::Card.new('2', '♣')] }

      it 'adds card which is higher than last card on pot' do
        cards.push(Brigitte::Card.new('3', '♣'))
        described_class.process(player, cards, pot)
        expect(cards.all? { |card| pot.last(cards.count).include?(card) }).to be_truthy
      end
    end
    context 'when thrown card is 10' do
      let(:pot) { [Brigitte::Card.new('A', '♣')] }
      it 'empties pot' do
        cards.push(Brigitte::Card.new('10', '♠'))
        described_class.process(player, cards, pot)
        expect(pot).to be_empty
      end
    end
  end
end
