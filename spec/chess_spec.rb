require './lib/game'
require './lib/board'
require 'pathname'

describe Chess do
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
      FileUtils.rm_f('save/save3')
      game = Chess::Game.new
      allow(game).to receive(:gets).and_return('n', 'save/save3')
      game.start_game
      (0..game.board.rows - 1).each do |row|
        (0..game.board.cols - 1).each do |col|
          game.board.assign_space(row, col, :king_b)
        end
      end
      game.save
      expect(FileUtils.compare_file('save/save3', 'spec/save3_spec')).to be true
    end
  end
end
