# frozen_string_literal: true

require_relative 'player'
require_relative 'card'
require_relative 'deck'
require_relative 'commands/pile'

module Brigitte
  #
  # A Game has maximum 4 players (+active_players+)
  # and can be started with +play+ method when all players are ready.
  class Game
    attr_accessor :current_player, :game_over
    attr_reader :active_players, :cards, :pile, :removed_cards, :winners

    def initialize
      @active_players = []
      @cards = []
      @pile = []
      @removed_cards = []
      @winners = []
      @game_over = false
    end

    #
    # Starts the game with the provided +players+.
    #
    # Returns this Game instance.
    #
    # ==== Arguments
    # +players+ - (Array) containing player names. Default strings of names.
    #
    # ==== Optional arguments
    # When +players+ is an array of hashes.
    #
    # +player_name_key+: - The key of name in player hash.
    #
    # +player_id_key+: - The key of id in player hash.
    #
    # ===== Examples
    #   start_new_game(['Bell', 'Biv', 'Devoe'])
    # or
    #   start_new_game(
    #     [{ name: 'Bell', id: 1 },
    #      { name: 'Biv', id: 2 },
    #      { name: 'Devoe', id: 3 }],
    #     player_name_key: :name,
    #     player_id_key: :id
    #   )
    def start_new_game(players, player_name_key: nil, player_id_key: nil)
      if player_name_key && player_id_key
        players.each do |p|
          @active_players << Player.new(p[player_name_key], p[player_id_key])
        end
      else
        players.each { |pn| @active_players << Player.new(pn) }
      end
      @cards = Deck.new.cards
      deal_cards

      self
    end

    def play
      return false unless @active_players.all?(&:ready)
      return @current_player if @current_player

      @current_player = @active_players.min do |p1, p2|
        p1.hand.map(&:order_level).min <=> p2.hand.map(&:order_level).min
      end
    end

    def throw_cards(player, *thrown_cards)
      return false unless player == @current_player
      return false unless Commands::Pile::AddCards.process(
        player, thrown_cards, @pile, @removed_cards
      )

      take_cards(player)
      take_visible_cards(player)
      player_won(player)
      select_next_player

      true
    end

    def take_cards_from_pile(player)
      return false unless player == @current_player

      player.hand.push(*@pile.pop(@pile.count))
      player.sort_hand!

      select_next_player(force: true) unless @game_over
    end

    def take_blind_card(player, blind_card_index)
      return false if player != @current_player
      return false if @cards.any?
      return false if player.visible_cards.any?
      return false if player.hand.any?

      player.pull_blind_card(blind_card_index)
    end

    def to_h
      {
        active_players: active_players.map(&:to_h),
        cards: cards.map(&:to_h),
        pile: pile.map(&:to_h),
        removed_cards: removed_cards.map(&:to_h),
        current_player: current_player.to_h,
        winners: winners.map(&:to_h),
        game_over: game_over
      }
    end

    def self.from_h(hash) # rubocop:disable Metrics/AbcSize
      game = new
      hash[:active_players].each { |h| game.active_players << Player.from_h(h) }
      hash[:cards].each { |h| game.cards << Card.from_h(h) }
      hash[:pile].each { |h| game.pile << Card.from_h(h) }
      hash[:removed_cards].each { |h| game.removed_cards << Card.from_h(h) }
      game.current_player = Player.from_h(hash[:current_player])
      hash[:winners].each { |h| game.winners << Player.from_h(h) }
      game.game_over = hash[:game_over]

      game
    end

    private

    def deal_cards
      @active_players.each do |player|
        3.times { player.blind_cards << @cards.pop }
        3.times { player.visible_cards << @cards.pop }
        3.times { player.hand << @cards.pop }
      end
    end

    def take_cards(player)
      return if @cards.empty?
      return if player.hand.count >= 3

      player.hand.push(*@cards.pop(3 - player.hand.count))
      player.sort_hand!
    end

    def take_visible_cards(player)
      return if @cards.any?
      return if player.hand.any?
      return if player.visible_cards.empty?

      player.hand.push(*player.visible_cards.pop(player.visible_cards.count))
      player.sort_hand!
    end

    def select_next_player(force: false)
      return if @game_over
      return if !force && player_can_throw_again?(@current_player)

      current_player_index = @active_players.index(@current_player)
      next_player_index = (current_player_index + 1) % @active_players.count

      @current_player = @active_players[next_player_index]
      select_next_player if @winners.include?(@current_player)
    end

    def player_won(player)
      return if @winners.include? player
      return if player.blind_cards.compact.any?
      return if player.hand.any?

      @winners << player
      verify_and_set_game_over
    end

    def verify_and_set_game_over
      remaining_players = @active_players.reject do |active_player|
        @winners.include? active_player
      end
      return if remaining_players.count > 1

      @winners << remaining_players.first if remaining_players.first
      @game_over = true
    end

    def player_can_throw_again?(player)
      return false if @winners.include?(player)

      @pile.empty?
    end
  end
end
