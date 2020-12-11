# frozen_string_literal: true

require 'securerandom'

module Brigitte
  #
  # A Player in Brigitte has a:
  # +hand+ where from player can only throw cards from
  # +visible_cards+ where from player can draw from if hands are empty
  # +blind_cards+ cards that are face down where from player can take only one
  # if all cards are played
  #
  # A player is ready if cards are swapped between it's +hand+
  # and +visible_cards+
  class Player
    attr_accessor :name, :hand, :blind_cards, :visible_cards, :ready
    attr_reader :id

    def initialize(name, id = nil)
      @id = id || SecureRandom.uuid
      @name = name
      @hand = []
      @blind_cards = []
      @visible_cards = []
      @ready = false

      yield self if block_given?
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

    def pull_blind_card(index)
      return false if hand.any?
      return false if visible_cards.any?

      blind_card = blind_cards[index]
      return false unless blind_card

      blind_cards[index] = nil
      hand << blind_card
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
        blind_cards: blind_cards.map(&:to_h),
        visible_cards: visible_cards.map(&:to_h),
        ready: ready
      }
    end

    def self.from_h(hash) # rubocop:disable Metrics/AbcSize
      return if hash.empty?

      new(hash[:name], hash[:id]) do |p|
        p.hand = hash[:hand].map { |h| Card.from_h(h) }
        p.blind_cards = hash[:blind_cards].map { |h| Card.from_h(h) }
        p.visible_cards = hash[:visible_cards].map { |h| Card.from_h(h) }
        p.ready = hash[:ready]
      end
    end
  end
end
