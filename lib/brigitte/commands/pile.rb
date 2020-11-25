# frozen_string_literal: true

module Brigitte
  module Commands
    module Pile
      #
      # Command that evaluates and adds cards on pile
      class AddCards
        class << self
          def process(player, cards, pile, removed_cards = [])
            return false unless valid?(player, cards, pile)

            pile.push(*cards.dup.map { |c| player.hand.delete(c) })
            removed_cards.push(*pile.pop(pile.count)) if clear_pile?(pile)

            true
          end

          def valid?(player, cards, pile)
            # player has cards
            return false unless (cards - player.hand).empty?
            # all cards are equal
            return false unless cards.uniq(&:weight).count == 1
            return true if pile.empty?
            # wild cards
            return true if [2, 10].include?(cards.first.weight)

            can_put_on_card?(cards.first, pile.last)
          end

          private

          def can_put_on_card?(top_card, down_card)
            operator = down_card.weight == 7 ? '<=' : '>='
            top_card.weight.send(operator, down_card.weight)
          end

          def clear_pile?(pile)
            return true if pile.last.weight == 10
            return false unless pile.count >= 4

            pile.last(4).uniq(&:weight).count == 1
          end
        end
      end
    end
  end
end
