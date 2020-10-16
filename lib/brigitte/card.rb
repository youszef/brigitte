# frozen_string_literal: true

require 'securerandom'

module Brigitte
  class Card
    include Comparable
    attr_reader :id, :value, :sign
    def initialize(value, sign, id=nil)
      @id = id || SecureRandom.uuid
      @value = value
      @sign = sign
    end

    def ==(other)
      id == other.id
    end

    def to_s
      value + sign
    end

    def weight
      return 11 if @value == 'J'
      return 12 if @value == 'Q'
      return 13 if @value == 'K'
      return 14 if @value == 'A'

      value.to_i
    end

    def to_h
      {
        id: id,
        value: value,
        sign: sign
      }
    end

    def self.from_h(card_hash)
      return if card_hash.empty?

      new(
        card_hash[:value],
        card_hash[:sign],
        card_hash[:id]
      )
    end
  end
end
