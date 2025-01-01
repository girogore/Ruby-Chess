require './lib/game'
require './lib/board'
require 'pathname'

describe Chess do
  # Generates an empty gameboard, optional piece can be placed at 2E (1,4)
  def blank_board!(game, piece = :empty)
    game.start_game(ask: false)
    (0..game.board.rows - 1).each do |row|
      (0..game.board.cols - 1).each do |col|
        game.board.assign_space(row, col, :empty)
      end
    end
    game.board.assign_space(1, 4, piece)
  end

  describe '#start_game' do
    it 'Initialize the board to default state' do
      board = Chess::Board.new
      expect(board.board[0].map(&:piece)).to eql(%i[rook_w knight_w bishop_w queen_w king_w bishop_w knight_w rook_w])
    end
  end
  describe '#load' do
    it 'Load board completely filled with white kings' do
      game = Chess::Game.new
      allow(game).to receive(:gets).and_return('Y', 'spec/save2_spec')
      game.start_game
      expect(game.board.board[0].map(&:piece)).to eql(%i[king_w king_w king_w king_w king_w king_w king_w king_w])
    end
  end
  describe '#save' do
    it 'Save board completely filled with black kings' do
      save_file = 'save/save3'
      FileUtils.rm_f(save_file)
      game = Chess::Game.new
      allow(game).to receive(:gets).and_return('n', save_file)
      game.start_game
      (0..game.board.rows - 1).each do |row|
        (0..game.board.cols - 1).each do |col|
          game.board.assign_space(row, col, :king_b)
        end
      end
      game.save
      expect(FileUtils.compare_file(save_file, 'spec/save3_spec')).to be true
    end
  end
  describe '#Allowed Moves' do
    context 'Check move validity for pieces' do
      it 'Move white Pawn up 1' do
        game = Chess::Game.new
        blank_board!(game, :pawn_w)
        move = game.process_input('2E3E')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white Pawn up 2' do
        game = Chess::Game.new
        blank_board!(game, :pawn_w)
        move = game.process_input('2E4E')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white Bishop' do
        game = Chess::Game.new
        blank_board!(game, :bishop_w)
        move = game.process_input('2E5H')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white Knight' do
        game = Chess::Game.new
        blank_board!(game, :knight_w)
        move = game.process_input('2E3G')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white Rook' do
        game = Chess::Game.new
        blank_board!(game, :rook_w)
        move = game.process_input('2E7E')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white Queen (diagonal)' do
        game = Chess::Game.new
        blank_board!(game, :queen_w)
        move = game.process_input('2E6A')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white Queen (vertical)' do
        game = Chess::Game.new
        blank_board!(game, :queen_w)
        move = game.process_input('2E5E')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white King' do
        game = Chess::Game.new
        blank_board!(game, :king_w)
        move = game.process_input('2E1E')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
    end
  end

  describe '#Legal_move_list' do
    context 'List legal moves for a piece at [4,5]' do
      it 'Pawn' do
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(4, 5, :pawn_w)
        game.board.assign_space(5, 6, :pawn_b) # Add a piece to attack diagonal
        expect(game.game_logic.piece_movement_reach([4, 5]).sort).to eql([[5, 5], [5, 6]].sort)
      end
      it 'Pawn : En passant' do
        game = Chess::Game.new
        blank_board!(game)
        pawn_array = [[2, 3], [2, 4]].sort
        game.board.assign_space(0, 0, :king_w)
        game.board.assign_space(7, 0, :king_b)
        game.board.assign_space(1, 4, :pawn_w)
        game.board.assign_space(3, 3, :pawn_b)
        game.process_turn('2e4e')
        expect(game.game_logic.piece_movement_reach([3, 3]).sort).to eql(pawn_array)
      end
      it 'Pawn : NOT En passant' do
        game = Chess::Game.new
        blank_board!(game)
        pawn_array = [[2, 3]].sort
        game.board.assign_space(0, 0, :king_w)
        game.board.assign_space(7, 0, :king_b)
        game.board.assign_space(1, 4, :rook_w)
        game.board.assign_space(3, 3, :pawn_b)
        game.process_turn('2e4e')
        expect(game.game_logic.piece_movement_reach([3, 3]).sort).to eql(pawn_array)
      end
      it 'Bishop' do
        bishop_array = [[5, 6], [6, 7], [5, 4], [6, 3], [3, 6], [2, 7], [3, 4], [2, 3]].sort
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(4, 5, :bishop_w)
        expect(game.game_logic.piece_movement_reach([4, 5]).sort).to eql(bishop_array)
      end
      it 'Knight' do
        knight_array = [[6, 6], [6, 4], [5, 7], [5, 3], [3, 3], [3, 7], [2, 4], [2, 6]].sort
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(4, 5, :knight_w)
        expect(game.game_logic.piece_movement_reach([4, 5]).sort).to eql(knight_array)
      end
      it 'Rook' do
        rook_array = [[5, 5], [6, 5], [3, 5], [2, 5], [4, 6], [4, 7], [4, 4], [4, 3], [4, 2], [4, 1], [4, 0]].sort
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(4, 5, :rook_w)
        expect(game.game_logic.piece_movement_reach([4, 5]).sort).to eql(rook_array)
      end
      it 'Queen' do
        queen_array = [[5, 5], [6, 5], [3, 5], [2, 5], [4, 6], [4, 7], [4, 4], [4, 3], [4, 2], [4, 1], [4, 0],
                       [5, 6], [6, 7], [5, 4], [6, 3], [3, 6], [2, 7], [3, 4], [2, 3]].sort
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(4, 5, :queen_w)
        expect(game.game_logic.piece_movement_reach([4, 5]).sort).to eql(queen_array)
      end
      it 'King' do
        king_array = [[4, 4], [4, 6], [3, 4], [3, 5], [3, 6]].sort
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(4, 5, :king_w)
        game.board.assign_space(0, 4, :empty) # remove the old king
        expect(game.game_logic.piece_movement_reach([4, 5]).sort).to eql(king_array)
      end
      it 'King : Castle' do
        king_array = [[0, 2], [0, 3]].sort
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(0, 3, :empty) # remove the queen/bishop/knight
        game.board.assign_space(0, 2, :empty)
        game.board.assign_space(0, 1, :empty)
        expect(game.game_logic.piece_movement_reach([0, 4]).sort).to eql(king_array)
      end
      it 'Disallow Checking yourself' do
        game = Chess::Game.new
        blank_board!(game, :king_w)
        game.board.assign_space(2, 4, :bishop_w)
        game.board.assign_space(6, 4, :rook_b) # Rook is attacking the king if the bishop moves
        expect(game.game_logic.piece_movement_reach([2, 4]).sort).to eql([])
      end
    end
  end
  describe '#Check' do
    context 'Place king in various checks' do
      it 'NOT Check' do
        game = Chess::Game.new
        game.start_game(ask: false)
        expect(game.game_logic.check?('white')).to be false
      end
      it 'Queen Check' do
        game = Chess::Game.new
        blank_board!(game)
        game.board.assign_space(4, 5, :king_w)
        game.board.assign_space(7, 5, :queen_b)
        expect(game.game_logic.check?('white')).to be true
      end
      it 'NOT Checkmate' do
        game = Chess::Game.new
        blank_board!(game)
        game.board.assign_space(0, 4, :king_w)
        game.board.assign_space(1, 4, :queen_b) # King takes the queen
        expect(game.game_logic.checkmate?('white', game.board.board)).to be false
      end
      it 'Checkmate' do
        game = Chess::Game.new
        blank_board!(game)
        game.board.assign_space(0, 4, :king_w)
        game.board.assign_space(1, 4, :queen_b)
        game.board.assign_space(6, 4, :rook_b) # defends the queen
        expect(game.game_logic.checkmate?('white', game.board.board)).to be true
      end
    end
  end

  describe '#force_move' do
    context 'Move pieces' do
      it 'Move white king : Castle' do
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(0, 3, :empty) # remove the queen/bishop/knight
        game.board.assign_space(0, 2, :empty)
        game.board.assign_space(0, 1, :empty)
        game.move([0, 4], [0, 2])
        expect(game.board.board[0].map(&:piece)).to eql(%i[empty empty king_w rook_w empty bishop_w knight_w rook_w])
      end
      it 'Fail to move white king : Castle' do
        game = Chess::Game.new
        game.start_game(ask: false)
        game.board.assign_space(0, 3, :empty) # remove the queen/bishop/knight
        game.board.assign_space(0, 2, :empty)
        game.board.assign_space(0, 1, :empty)
        game.board.assign_space(1, 4, :empty) # Pawn above king
        game.move([0, 4], [1, 4])
        game.move([1, 4], [0, 4]) # Move the king
        expect(game.move([0, 4], [0, 2])).to be false
      end
      it 'Fail to move opponents piece' do
        game = Chess::Game.new
        blank_board!(game, :king_b)
        move = game.process_input('2E1E')
        expect(game.move(move[0], move[1])).to be false
      end
      it 'Promote a pawn' do
        game = Chess::Game.new
        blank_board!(game)
        game.board.assign_space(0, 0, :king_w)
        game.board.assign_space(7, 0, :king_b)
        game.board.assign_space(6, 4, :pawn_w)
        allow(game).to receive(:gets).and_return('E7 E8')
        allow(game.board).to receive(:gets).and_return('queen')
        game.process_turn
        expect(game.board.board[7].map(&:piece)).to eql(%i[king_b empty empty empty queen_w empty empty empty])
      end
    end
    context 'Move is blocked by piece' do
      it 'Try to move through a wall of pawns' do
        game = Chess::Game.new
        blank_board!(game)
        (0..game.board.cols - 1).each { |col| game.board.assign_space(4, col, :pawn_b) }
        move = game.process_input('7E2E')
        expect(game.game_logic.collision?(move[0], move[1])).to be true
      end
    end
  end

  describe '#Test Game' do
    it 'Play game : Scholor Mate' do
      game = Chess::Game.new
      allow(game).to receive(:gets)
        .and_return('n',
                    'e2e4', 'e7e5',
                    '1fc4', 'b8c6',
                    'd15h', '8gf6',
                    'h5f7')
      game.start_game
      7.times { game.process_turn }
      expect(game.game_logic.checkmate?('black')).to be true
    end
    it 'Play game : 20turn draw' do
      game = Chess::Game.new
      allow(game).to receive(:gets)
        .and_return('n',
                    'e2e3', 'a7a5',
                    'd1h5', 'a8a6',
                    'h5a5', 'h7h5',
                    'h2h4', 'a6h6',
                    'a5c7', 'f7f6',
                    'c7d7', 'e8f7',
                    'd7b7', 'd8d3',
                    'b7b8', 'd3h7',
                    'b8c8', 'f7g6',
                    'c8e6')
      game.start_game
      19.times { game.process_turn }
      expect(game.game_logic.checkmate?('black')).to be true
      expect(game.who_won).to eql(:draw)
    end
  end
end
