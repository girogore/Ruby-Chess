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
    winner.nil? ? puts('No winner!') : puts("Player #{winner} won!")
  end
end

def test_moves
  game = Chess::Game.new
  game.start_game(ask: false)
  game.board.assign_space(4, 5, :king_w)
  game.board.assign_space(0, 4, :empty) # remove the old king
  p game.game_logic.piece_movement_reach([4, 5]).sort
  # game.game_logic.check?('white')
  puts game
end
test_moves

# Chess.play_game
