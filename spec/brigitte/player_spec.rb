# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brigitte::Player, type: :model do
  let(:player) { described_class.new('test_user') }
  let(:cards) { Brigitte::Deck.new.cards }

  describe '#initialize' do
    it 'sets id' do
      player = described_class.new('test_user')
      expect(player.id).not_to be_nil
      expect(player.id).not_to eq ''
    end

    it 'sets name' do
      expect(described_class.new('test_user').name).to eq('test_user')
    end

    it 'should not be ready' do
      expect(described_class.new('test_user')).not_to be_ready
    end
  end
  describe '#ready!' do
    it 'sets ready to true' do
      player.ready!
      expect(player).to be_ready
    end
  end
  describe '#swap' do
    let(:hand_card) { cards.pop }
    let(:visible_card) { cards.pop }

    before do
      player.hand << hand_card
      player.visible_cards << visible_card
    end

    it 'does not swap card when player is ready' do
      player.ready!
      player.swap(hand_card, visible_card)
      expect(player.hand.index(visible_card)).to be_nil
      expect(player.visible_cards.index(hand_card)).to be_nil
    end
    it 'does not swap card when player does not have card in hand' do
      new_card = cards.pop
      player.swap(new_card, visible_card)
      expect(player.hand.index(visible_card)).to be_nil
      expect(player.visible_cards.index(new_card)).to be_nil
    end
    it 'does not swap card when player does not have card on table' do
      new_card = cards.pop
      player.swap(hand_card, new_card)
      expect(player.hand.index(new_card)).to be_nil
      expect(player.visible_cards.index(hand_card)).to be_nil
    end
    it 'swaps card' do
      player.swap(hand_card, visible_card)
      expect(player.hand.index(visible_card)).not_to be_nil
      expect(player.visible_cards.index(hand_card)).not_to be_nil
    end
  end
  describe '#throw' do
    it 'throws card from hand' do
      card = cards.pop
      player.hand << card
      expect(player.hand.index(card)).not_to be_nil
      player.throw(card)
      expect(player.hand.index(card)).to be_nil
    end
  end
  describe '#pull_hidden_card' do
    before do
      player.hidden_cards = cards.pop(3)
    end
    context 'when there are still visible cards on table' do
      before do
        player.visible_cards = cards.pop(3)
      end
      it 'does not pull card' do
        player.pull_hidden_card(0)
        expect(player.hidden_cards.compact.count).to eq 3
      end
    end
    context 'when there are still cards in hand' do
      before do
        player.hand = cards.pop(1)
      end
      it 'does not pull card' do
        player.pull_hidden_card(0)
        expect(player.hidden_cards.compact.count).to eq 3
      end
    end
    context 'when hidden cards are available' do
      it 'pulls only one card' do
        player.pull_hidden_card(0)
        expect(player.hidden_cards.compact.count).to eq 2
      end

      it 'keeps other cards at the same index' do
        last_hidden_card = player.hidden_cards.last
        player.pull_hidden_card(1)

        expect(player.hidden_cards[1]).to be_nil
        expect(player.hidden_cards[2]).to eq last_hidden_card
      end
    end
  end
end
