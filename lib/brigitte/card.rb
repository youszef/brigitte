# frozen_string_literal: true

require 'securerandom'

module Brigitte
  class Card
    include Comparable
    attr_reader :id, :value, :sign
    def initialize(value, sign)
      @id = SecureRandom.uuid
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
  end
end
