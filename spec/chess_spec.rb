require './lib/game'
require './lib/board'
require 'pathname'

SAVE = 'save/'.freeze
SPEC = 'spec/'.freeze

describe Chess do
  # Generates an empty gameboard, optional piece can be placed at 2E
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
      it 'Move white pawn up 1' do
        game = Chess::Game.new
        blank_board!(game, :pawn_w)
        move = game.process_input('2E3E')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white pawn up 2' do
        game = Chess::Game.new
        blank_board!(game, :pawn_w)
        move = game.process_input('2E4E')
        expect(game.game_logic.legal_move?(move[0], move[1])).to be true
      end
      it 'Move white bishop' do
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

  describe '#force_move' do
    context 'Move pieces uninhibited' do
      it 'Move white pawn up 1' do
        save_file = 'pawn1_success'
        FileUtils.rm_f(SAVE + save_file)
        game = Chess::Game.new
        allow(game).to receive(:gets).and_return('2E 3E', SAVE + save_file)
        blank_board!(game, :pawn_w)
        game.process_turn
        game.save
        expect(FileUtils.compare_file(SAVE + save_file, "#{SPEC}#{save_file}")).to be true
      end
      it 'Move white pawn up 2' do
        save_file = 'pawn2_success'
        FileUtils.rm_f(SAVE + save_file)
        game = Chess::Game.new
        allow(game).to receive(:gets).and_return('2E 4E', SAVE + save_file)
        blank_board!(game, :pawn_w)
        game.process_turn
        game.save
        expect(FileUtils.compare_file(SAVE + save_file, "#{SPEC}#{save_file}")).to be true
      end
      it 'Move white bishop diagonal 3' do
        save_file = 'bishop_success'
        FileUtils.rm_f(SAVE + save_file)
        game = Chess::Game.new
        allow(game).to receive(:gets).and_return('2E 5H', SAVE + save_file)
        blank_board!(game, :bishop_w)
        game.process_turn
        game.save
        expect(FileUtils.compare_file(SAVE + save_file, "#{SPEC}#{save_file}")).to be true
      end
      it 'Move white rook up 5' do
        save_file = 'rook_success'
        FileUtils.rm_f(SAVE + save_file)
        game = Chess::Game.new
        allow(game).to receive(:gets).and_return('2E 7E', SAVE + save_file)
        blank_board!(game, :rook_w)
        game.process_turn
        game.save
        expect(FileUtils.compare_file(SAVE + save_file, "#{SPEC}#{save_file}")).to be true
      end
      it 'Move white knight' do
        save_file = 'knight_success'
        FileUtils.rm_f(SAVE + save_file)
        game = Chess::Game.new
        allow(game).to receive(:gets).and_return('2E 3G', SAVE + save_file)
        blank_board!(game, :knight_w)
        game.process_turn
        game.save
        expect(FileUtils.compare_file(SAVE + save_file, "#{SPEC}#{save_file}")).to be true
      end
      it 'Move white queen diagonal' do
        save_file = 'queen_success'
        FileUtils.rm_f(SAVE + save_file)
        game = Chess::Game.new
        allow(game).to receive(:gets).and_return('2E A6', SAVE + save_file)
        blank_board!(game, :queen_w)
        game.process_turn
        game.save
        expect(FileUtils.compare_file(SAVE + save_file, "#{SPEC}#{save_file}")).to be true
      end
      it 'Move white king back' do
        save_file = 'king_success'
        FileUtils.rm_f(SAVE + save_file)
        game = Chess::Game.new
        allow(game).to receive(:gets).and_return('2E 1E', SAVE + save_file)
        blank_board!(game, :king_w)
        game.process_turn
        game.save
        expect(FileUtils.compare_file(SAVE + save_file, "#{SPEC}#{save_file}")).to be true
      end
      it 'Fail to move opponents piece' do
        game = Chess::Game.new
        blank_board!(game, :king_b)
        move = game.process_input('2E1E')
        expect(game.move(move[0], move[1])).to be false
      end
    end
    context 'Move is blocked by piece' do
      it 'Try to move through a wall of pawns' do
        game = Chess::Game.new
        blank_board!(game)
        (0..game.board.cols - 1).each { |col| game.board.assign_space(4, col, :pawn_b) }
        move = game.process_input('7E2E')
        expect(game.board.collision?(move[0], move[1])).to be true
      end
    end
  end
end
