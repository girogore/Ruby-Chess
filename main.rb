require_relative 'lib/game'

# Module that creates and allows players to play chess
module Chess
  def self.play_game
    game = Chess::Game.new
    while game.playing?
      puts game
      game.process_turn
    end
    puts game
    winner = game.who_won
    winner.nil? ? puts('No winner!') : puts("Player #{winner} won!")
  end
end

Chess.play_game
