# frozen_string_literal: true

require_relative 'player'
require_relative 'card'
require_relative 'deck'
require_relative 'commands/pot'

module Brigitte
  class Game
    attr_writer :current_player, :game_over
    attr_reader :active_players, :cards, :pot, :current_player, :removed_cards, :won_players, :game_over

    def initialize
      @active_players = []
      @cards = []
      @pot = []
      @removed_cards = []
      @won_players = []
      @game_over = false
    end

    ##
    # Starts the game with the provided +players+.
    # Returns this Game instance.
    #
    # +players+ - An array containing player names. Default strings of names.
    #
    # ==== Optional arguments
    # * If +players+ is an array of hashes.
    # * +:player_name_key+ - The key of name in player hash.
    # * +:player_id_key+ - The key of id in player hash.
    #
    # ===== Examples
    #   start_new_game(['Bell', 'Biv', 'Devoe'])
    #
    #   start_new_game([{ name: 'Bell', id: 1 }, { name: 'Biv', id: 2 }, { name: 'Devoe', id: 3 }],
    #                   player_name_key: :name,
    #                   player_id_key: :id
    #                 )
    def start_new_game(players, args = {})
      if args.empty?
        players.each { |pn| @active_players << Player.new(pn) }
      else
        players.each { |p| @active_players << Player.new(p[args[:player_name_key]], p[args[:player_id_key]]) }
      end
      @cards = Deck.new.cards
      deal_cards

      self
    end

    def play
      return false unless @active_players.all?(&:ready)

      @current_player ||= @active_players.min { |player1, player2| player1.hand.map(&:weight).min <=> player2.hand.map(&:weight).min }
    end

    def throw_cards(player, *thrown_cards)
      return false unless player == @current_player

      success = Commands::Pot::AddCards.process(player, thrown_cards, @pot, @removed_cards)

      if success
        if @cards.any?
          take_cards(player)
        elsif player.visible_cards.any?
          take_visible_cards(player)
        elsif player.hidden_cards.compact.empty? && player.hand.empty?
          @won_players << player
          check_and_set_game_over
        end

        set_next_player unless @game_over
      end
      success
    end

    def take_cards_from_pot(player)
      return false unless player == @current_player

      player.hand.push(*@pot.pop(@pot.count))
      player.sort_hand!

      set_next_player(true) unless @game_over
    end

    def take_hidden_card(player, hidden_card_index)
      return false if player != @current_player
      return false if @cards.any?
      return false if player.visible_cards.any?
      return false if player.hand.any?

      player.pull_hidden_card(hidden_card_index)
    end

    def to_h
      {
        active_players: active_players.map(&:to_h),
        cards: cards.map(&:to_h),
        pot: pot.map(&:to_h),
        removed_cards: removed_cards.map(&:to_h),
        current_player: current_player.to_h,
        won_players: won_players.map(&:to_h),
        game_over: game_over
      }
    end

    def self.from_h(game_hash)
      game = new
      game_hash[:active_players].each { |h| game.active_players << Player.from_h(h) }
      game_hash[:cards].each { |h| game.cards << Card.from_h(h) }
      game_hash[:pot].each { |h| game.pot << Card.from_h(h) }
      game_hash[:removed_cards].each { |h| game.removed_cards << Card.from_h(h) }
      game.current_player = Player.from_h(game_hash[:current_player])
      game_hash[:won_players].each { |h| game.won_players << Player.from_h(h) }
      game.game_over = game_hash[:game_over]

      game
    end

    private

      def deal_cards
        @active_players.each do |player|
          3.times { player.hidden_cards << @cards.pop }
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

        player.hand.push(*player.visible_cards.pop(player.visible_cards.count))
        player.sort_hand!
      end

      def set_next_player(force=false)
        return if !force && player_can_throw_again?(@current_player)

        current_player_index = @active_players.index(@current_player)
        next_player_index = (current_player_index + 1) % @active_players.count

        @current_player = @active_players[next_player_index]
        set_next_player if @won_players.include?(@current_player)
      end

      def check_and_set_game_over
        remaining_players = @active_players.reject{ |active_player| @won_players.include? active_player }
        return if remaining_players.count > 1

        @won_players << remaining_players.first
        @game_over = true
      end

      def player_can_throw_again?(player)
        return false if @won_players.include?(player)

        @pot.empty?
      end
  end
end
