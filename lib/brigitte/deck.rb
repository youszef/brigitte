# frozen_string_literal: true

module Brigitte
  #
  # A Deck generates and shuffles all cards except Joker.
  # Joker is not used in Brigitte
  class Deck
    attr_accessor :cards

    SIGNS = %w[♣ ♦ ♥ ♠].freeze
    PREFIX = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

    def initialize
      @cards = PREFIX.map do |prefix|
        SIGNS.map { |sign| Card.new(prefix, sign) }
      end.flatten.shuffle
    end
  end
end
