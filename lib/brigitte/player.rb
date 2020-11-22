# frozen_string_literal: true

require 'securerandom'

module Brigitte
  class Player
    attr_accessor :name, :hand, :hidden_cards, :visible_cards, :ready
    attr_reader :id

    def initialize(name, id=nil)
      @id = id || SecureRandom.uuid
      @name = name
      @hand = []
      @hidden_cards = []
      @visible_cards = []
      @ready = false
    end

    def ready!
      sort_hand!
      @ready = true
    end

    def ready?
      @ready
    end

    def ==(other)
      id == other&.id
    end

    def swap(hand_card, visible_card)
      return if @ready

      hand_card_index = hand.find_index(hand_card)
      visible_card_index = visible_cards.find_index(visible_card)
      return unless hand_card_index
      return unless visible_card_index

      visible_cards[visible_card_index] = hand_card
      hand[hand_card_index] = visible_card
    end

    def pull_hidden_card(index)
      return false if hand.any?
      return false if visible_cards.any?

      hidden_card = hidden_cards[index]
      return false unless hidden_card

      hidden_cards[index] = nil
      hand << hidden_card
      sort_hand!
      true
    end

    def throw(card)
      hand.delete(card)
    end

    def sort_hand!
      hand.sort_by!(&:weight).reverse!
    end

    def to_h
      {
        id: id,
        name: name,
        hand: hand.map(&:to_h),
        hidden_cards: hidden_cards.map(&:to_h),
        visible_cards: visible_cards.map(&:to_h),
        ready: ready
      }
    end

    def self.from_h(player_hash)
      return if player_hash.empty?

      player = new(
        player_hash[:name],
        player_hash[:id]
      )

      player.hand = player_hash[:hand].map{ |h| Card.from_h(h) }
      player.hidden_cards = player_hash[:hidden_cards].map{ |h| Card.from_h(h) }
      player.visible_cards = player_hash[:visible_cards].map{ |h| Card.from_h(h) }
      player.ready = player_hash[:ready]

      player
    end
  end
end
