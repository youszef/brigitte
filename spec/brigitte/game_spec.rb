# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brigitte::Game, type: :model do
  let(:player_names) { %w[player1 player2 player3] }

  describe '#initialize' do
    it 'initializes all attributes' do
      game = described_class.new

      expect(game.active_players).to eq []
      expect(game.cards).to eq []
      expect(game.pot).to eq []
      expect(game.removed_cards).to eq []
      expect(game.won_players).to eq []
      expect(game.game_over).to be_falsey
    end
  end

  describe '#start_new_game' do
    context 'when array of player names string' do
      it 'sets active_players' do
        game = described_class.new.start_new_game(player_names)
        expect(game.active_players.map(&:name)).to eq player_names
      end

      it 'sets new deck of cards' do
        game = described_class.new.start_new_game(player_names)
        expect(game.cards.all? { |card| card.is_a? Brigitte::Card }).to be_truthy
        expect(game.cards.count).to eq(52 - (game.active_players.count * 9))
      end
    end
    context 'when array of player hash' do
      let(:player_hashes) { [{ name: 'Bell', id: 1 }, { name: 'Biv', id: 2 }, { name: 'Devoe', id: 3 }] }

      it 'sets active_players' do
        game = described_class.new.start_new_game(player_hashes, player_name_key: :name, player_id_key: :id)
        expect(game.active_players.map(&:name)).to eq player_hashes.map{ |p| p[:name] }
      end

      it 'sets new deck of cards' do
        game = described_class.new.start_new_game(player_hashes, player_name_key: :name, player_id_key: :id)
        expect(game.cards.all? { |card| card.is_a? Brigitte::Card }).to be_truthy
        expect(game.cards.count).to eq(52 - (game.active_players.count * 9))
      end
    end
  end

  describe '#deal_cards' do
    let(:game) { described_class.new.start_new_game(player_names) }

    it 'gives each user 3 hidden cards' do
      expect(game.active_players.all? { |player| player.hidden_cards.count == 3 }).to be_truthy
    end
    it 'gives each user 3 visible cards' do
      expect(game.active_players.all? { |player| player.visible_cards.count == 3 }).to be_truthy
    end
    it 'gives each user 3 hand cards' do
      expect(game.active_players.all? { |player| player.hand.count == 3 }).to be_truthy
    end
  end
  describe '#play' do
    context 'when not all active_players are ready' do
      let(:game) { described_class.new.start_new_game(player_names) }

      before do
        game.active_players.first.ready!
      end

      it 'returns false' do
        expect(game.play).to be_falsey
      end
      it 'does not set current_player yet' do
        expect(game.current_player).to be_nil
      end
    end
    context 'when all active_players are ready' do
      let(:game) { described_class.new.start_new_game(player_names) }

      before do
        game.active_players.each(&:ready!)
      end

      it 'returns false' do
        expect(game.play).to be_truthy
      end
      it 'does not set current_player yet' do
        game.play
        expect(game.current_player).not_to be_nil
      end
    end
  end
  describe '#throw_card' do
    let(:game) { described_class.new.start_new_game(player_names) }

    context 'when player who is not in turn throws card' do
      before do
        game.active_players.each(&:ready!)
        game.play
      end

      let(:player) { game.active_players.reject { |player| game.current_player == player }.first }

      it 'returns false' do
        expect(game.throw_card(player, player.hand.first)).to be_falsey
      end

      it 'does not throw card' do
        thrown_card = player.hand.first
        game.throw_card(player, thrown_card)
        expect(player.hand.include?(thrown_card)).to be_truthy
      end

      it 'does not take a card from deck of cards' do
        top_card_on_deck = game.cards.last
        game.throw_card(player, player.hand.first)
        expect(player.hand.include?(top_card_on_deck)).to be_falsey
      end

      it 'current_player stays the same' do
        current_player = game.current_player
        game.throw_card(player, player.hand.first)
        expect(game.current_player).to eq current_player
      end
    end
    context 'when player is in turn but throws card not in hand' do
      before do
        game.active_players.each(&:ready!)
        game.play
      end

      let(:player) { game.current_player }

      it 'returns false' do
        expect(game.throw_card(player, player.visible_cards.first)).to be_falsey
      end

      it 'does not throw card' do
        thrown_card = player.visible_cards.first
        game.throw_card(player, thrown_card)
        expect(player.visible_cards.include?(thrown_card)).to be_truthy
      end

      it 'does not take a card from deck of cards' do
        top_card_on_deck = game.cards.last
        game.throw_card(player, player.visible_cards.first)
        expect(player.hand.include?(top_card_on_deck)).to be_falsey
      end

      it 'current_player stays the same' do
        current_player = game.current_player
        game.throw_card(player, player.visible_cards.first)
        expect(game.current_player).to eq current_player
      end
    end
    context 'when player is in turn and throws card from hand' do
      let(:player) { game.current_player }

      context 'throws single card' do
        before do
          game.active_players.each(&:ready!)
          game.play
        end

        it 'returns true' do
          expect(game.throw_card(player, player.hand.first)).to be_truthy
        end

        it 'throws card from hand' do
          thrown_card = player.hand.first
          game.throw_card(player, thrown_card)
          expect(player.hand.include?(thrown_card)).to be_falsey
        end

        it 'takes a card from decks of card' do
          top_card_on_deck = game.cards.last
          game.throw_card(player, player.hand.first)
          expect(player.hand.include?(top_card_on_deck)).to be_truthy
        end

        it 'amount cards in hand is 3' do
          game.throw_card(player, player.hand.first)
          expect(player.hand.count).to eq 3
        end

        it 'next player is now in turn when pot is not empty' do
          next_player = game.active_players[(game.active_players.index(game.current_player) + 1) % game.active_players.count]
          game.throw_card(player, player.hand.first)
          if game.pot.any?
            expect(game.current_player).to eq next_player
          else
            expect(game.current_player).not_to eq next_player
          end
        end
      end

      context 'multiple cards' do
        before do
          game.active_players.each(&:ready!)
          game.play
        end

        context 'same weight' do
          before do
            thrown = []
            game.cards.delete_if { |card| thrown << card if card.weight == game.cards.last.weight }
            player.hand.clear
            player.hand.push(*thrown)
          end

          it 'returns true' do
            expect(game.throw_card(player, *player.hand)).to be_truthy
          end

          it 'throws card from hand' do
            thrown_cards = player.hand.dup
            game.throw_card(player, *thrown_cards)

            expect(thrown_cards.all? { |card| !player.hand.include?(card) }).to be_truthy
          end

          it 'takes a card from decks of card' do
            thrown_cards = player.hand.dup
            top_cards_on_deck = game.cards.last(3)
            game.throw_card(player, *thrown_cards)

            expect(top_cards_on_deck.all? { |card| player.hand.include?(card) }).to be_truthy
          end

          it 'amount cards in hand is 3' do
            game.throw_card(player, *player.hand)

            expect(player.hand.count).to eq 3
          end

          it 'current_player stays the same as pot has been emptied by the player' do
            amount_of_cards = player.hand.count
            game.throw_card(player, *player.hand)

            expect(game.current_player).to eq player if amount_of_cards == 4
          end
        end
        context 'different weight' do
          before do
            player.hand.clear
            player.hand << game.cards.pop
            player.hand << game.cards.select { |card| card.weight != player.hand.last.weight }.first
            player.hand << game.cards.select { |card| card.weight != player.hand.last.weight }.first
          end

          it 'returns false' do
            expect(game.throw_card(player, *player.hand)).to be_falsey
          end

          it 'does not throw card' do
            thrown_cards = player.hand.dup
            game.throw_card(player, *thrown_cards)
            expect(thrown_cards.all? { |card| player.hand.include?(card) }).to be_truthy
          end

          it 'does not take a card from deck of cards' do
            thrown_cards = player.hand.dup
            top_card_on_deck = game.cards.last
            game.throw_card(player, *thrown_cards)
            expect(player.hand.include?(top_card_on_deck)).to be_falsey
          end

          it 'current_player stays the same' do
            current_player = game.current_player
            game.throw_card(player, *player.hand)

            expect(game.current_player).to eq current_player
          end
        end
      end
    end
    context 'when only one card left on table' do
      before do
        game.active_players.each(&:ready!)
        game.cards.shift(game.cards.count - 1)
        game.play
      end

      let(:player) { game.current_player }

      context 'when no cards in hand' do
        before do
          player.hand.shift(player.hand.count - 1)
        end

        it 'returns true' do
          expect(game.throw_card(player, player.hand.first)).to be_truthy
        end

        it 'throws card from hand' do
          thrown_card = player.hand.first
          game.throw_card(player, thrown_card)
          expect(player.hand.include?(thrown_card)).to be_falsey
        end

        it 'takes a card from decks of card' do
          top_card_on_deck = game.cards.last
          game.throw_card(player, player.hand.first)
          expect(player.hand.include?(top_card_on_deck)).to be_truthy
        end

        it 'amount cards in hand is 1' do
          game.throw_card(player, player.hand.first)
          expect(player.hand.count).to eq 1
        end

        it 'next player is now in turn when pot is not empty' do
          next_player = game.active_players[(game.active_players.index(game.current_player) + 1) % game.active_players.count]
          game.throw_card(player, player.hand.first)
          if game.pot.any?
            expect(game.current_player).to eq next_player
          else
            expect(game.current_player).not_to eq next_player
          end
        end
      end
    end
    context 'when there are no cards left on table' do
      before do
        game.active_players.each(&:ready!)
        game.cards.clear
        game.play
      end

      let(:player) { game.current_player }

      context 'when player has 3 cards left in hand' do
        it 'throws card without needing to pick up card' do
          thrown_card = player.hand.first
          game.throw_card(player, thrown_card)

          expect(player.hand.include?(thrown_card)).to be_falsey
          expect(player.hand.count).to eq 2
        end
        it 'next player is in turn when pot is not empty' do
          next_player = game.active_players[(game.active_players.index(game.current_player) + 1) % game.active_players.count]
          game.throw_card(player, player.hand.first)

          if game.pot.any?
            expect(game.current_player).to eq next_player
          else
            expect(game.current_player).not_to eq next_player
          end
        end
      end
      context 'when hands become empty after throwing last card(s)' do
        before do
          player.hand.shift(player.hand.count - 1)
        end
        context 'when visible cards are available' do
          it 'takes all the visible cards into hand' do
            visible_cards = player.visible_cards
            game.throw_card(player, player.hand.first)

            expect(player.hand.count).to eq 3
            expect(player.hand).to include(*visible_cards)
          end

          it 'next player is in turn when pot is not empty' do
            next_player = game.active_players[(game.active_players.index(game.current_player) + 1) % game.active_players.count]
            game.throw_card(player, player.hand.first)

            if game.pot.any?
              expect(game.current_player).to eq next_player
            else
              expect(game.current_player).not_to eq next_player
            end
          end
        end
        context 'when visible cards are empty' do
          before do
            player.visible_cards.clear
          end

          it 'takes second card from hidden cards in hand' do
            taken_hidden_card = player.hidden_cards[1]
            game.throw_card(player, player.hand.first, hidden_card_index: 1)

            expect(player.hidden_cards.count).to eq 2
            expect(player.hand).to include(taken_hidden_card)
          end

          it 'next player is in turn when pot is not empty' do
            next_player = game.active_players[(game.active_players.index(game.current_player) + 1) % game.active_players.count]
            game.throw_card(player, player.hand.first, hidden_card_index: 1)

            if game.pot.any?
              expect(game.current_player).to eq next_player
            else
              expect(game.current_player).not_to eq next_player
            end
          end

          context 'hidden cards are empty' do
            before do
              player.hidden_cards.clear
            end

            it 'adds it to won_players' do
              game.throw_card(player, player.hand.first)

              expect(game.won_players.first).to eq player
            end

            it 'next player is now in turn' do
              next_player = game.active_players[(game.active_players.index(game.current_player) + 1) % game.active_players.count]
              game.throw_card(player, player.hand.first)

              expect(game.current_player).to eq next_player
            end
          end
          context 'when second to last player throws its last card' do

            before do
              player.hidden_cards.clear
              game.won_players << game.active_players.reject{ |p| p == game.current_player }.first
            end

            it 'is game over' do
              game.throw_card(player, player.hand.first)

              expect(game.game_over).to be_truthy
            end
          end
        end
      end
    end
  end

  describe 'serialisation' do
    it 'gives same content after deserialising on a new game' do
      game = described_class.new.start_new_game(player_names)
      h = game.to_h

      expect(described_class.from_h(h).to_h).to eq(h)
    end
  end
end
