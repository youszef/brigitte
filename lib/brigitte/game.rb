# frozen_string_literal: true

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

    def start_new_game(*player_names)
      player_names.each { |pn| @active_players << Player.new(pn) }
      @cards = Deck.new.cards
      deal_cards

      self
    end

    def play
      return false unless @active_players.map(&:ready).all?

      @current_player ||= @active_players.min { |player1, player2| player1.hand.map(&:weight).min <=> player2.hand.map(&:weight).min }
    end

    def throw_card(player, *thrown_cards, hidden_card_index: nil)
      return false unless player == @current_player

      success = Commands::Pot::AddCard.process(player, thrown_cards, @pot, @removed_cards)

      if success
        if @cards.any?
          take_cards(player)
        elsif player.visible_cards.any?
          take_visible_cards(player)
        elsif player.hidden_cards.any?
          take_hidden_card(player, hidden_card_index)
        else
          @won_players << player
          check_and_set_game_over
        end

        set_next_player unless @game_over
      end
      success
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
      end

      def take_visible_cards(player)
        return if @cards.any?
        return if player.hand.any?

        player.hand.push(*player.visible_cards.pop(player.visible_cards.count))
      end

      def take_hidden_card(player, hidden_card_index)
        return if player.visible_cards.any?
        return if player.hand.any?

        player.pull_hidden_card(hidden_card_index)
      end

      def set_next_player
        return if player_can_throw_again?(@current_player)

        current_player_index = @active_players.index(@current_player)
        next_player_index = (current_player_index + 1) % @active_players.count

        @current_player = @active_players[next_player_index]
        set_next_player if @won_players.include?(@current_player)
      end

      def check_and_set_game_over
        remaining_players = @active_players - @won_players
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
