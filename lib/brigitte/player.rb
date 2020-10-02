# frozen_string_literal: true

require 'securerandom'

module Brigitte
  class Player
    attr_accessor :name, :hand, :hidden_cards, :visible_cards, :ready
    attr_reader :id

    def initialize(name)
      @id = SecureRandom.uuid
      @name = name
      @hand = []
      @hidden_cards = []
      @visible_cards = []
      @ready = false
    end

    def ready!
      @ready = true
    end

    def ready?
      @ready
    end

    def ==(other)
      id == other.id
    end

    def swap(hand_card, visible_card)
      return if @ready

      hand_card_index = hand.find_index(hand_card)
      visible_card_index = visible_cards.find_index(visible_card)
      return unless hand_card_index
      return unless visible_card_index

      visible_cards << hand.delete_at(hand_card_index)
      hand << visible_cards.delete_at(visible_card_index)
    end

    def pull_hidden_card(index)
      return if hand.any?
      return if visible_cards.any?

      hidden_card = hidden_cards[index]
      return unless hidden_card

      hand << hidden_cards.delete_at(index)
    end

    def throw(card)
      hand.delete(card)
    end
  end
end
