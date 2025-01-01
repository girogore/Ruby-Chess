require_relative 'lib/game'

# Module that creates and allows players to play chess
module Chess
  def self.blank_board!(game, piece = :empty)
    game.start_game(ask: false)
    (0..game.board.rows - 1).each do |row|
      (0..game.board.cols - 1).each do |col|
        game.board.assign_space(row, col, :empty)
      end
    end
    game.board.assign_space(1, 4, piece)
  end

  def self.play_game
    game = Chess::Game.new
    game.start_game
    while game.playing?
      puts game
      game.process_turn
    end
    puts game
    winner = game.who_won
    winner == :draw ? puts('No winner!') : puts("Player #{winner} won!")
  end
end

# def test_moves
#   game = Chess::Game.new
#   Chess.blank_board!(game)
#   game.board.assign_space(0, 0, :king_w)
#   game.board.assign_space(7, 0, :king_b)
#   game.board.assign_space(6, 4, :pawn_w)
#   puts game
#   game.process_turn
#   puts game
# end
# test_moves

Chess.play_game
