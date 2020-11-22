# frozen_string_literal: true

module Brigitte
  module Commands
    module Pot
      class AddCards
        class << self
          def process(player, cards, pot, removed_cards = [])
            if valid?(player, cards, pot)
              pot.push(*cards.dup.map { |c| player.hand.delete(c) })
              if pot.last.weight == 10 || (pot.count >= 4 && pot.last(4).uniq(&:weight).count == 1)
                removed_cards.push(*pot.pop(pot.count))
              end

              return true
            end
            false
          end

          def valid?(player, cards, pot)
            return false if cards.empty?
            return false unless cards.all? { |card| player.hand.include?(card) }
            return false unless cards.uniq(&:weight).count == 1 # all cards are equal
            return true if pot.empty?
            return true if [2, 10].include?(cards.first.weight)
            return cards.first.weight <= pot.last.weight if pot.last.weight == 7

            cards.first.weight >= pot.last.weight
          end
        end
      end
    end
  end
end
