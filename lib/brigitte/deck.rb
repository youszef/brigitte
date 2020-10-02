# frozen_string_literal: true

module Brigitte
  class Deck
    attr_accessor :cards

    SIGNS = %w[♣ ♦ ♥ ♠].freeze
    PREFIX = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

    def initialize
      @cards = PREFIX.map { |prefix| SIGNS.map { |sign| Card.new(prefix, sign) } }.flatten.shuffle
    end
  end
end
