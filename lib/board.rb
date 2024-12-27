module Chess
  # Contains information for a chess board
  class Board
    attr_accessor :rows, :cols, :board

    def initialize
      @rows = 8
      @cols = 8
      @board = Array.new(@rows) { Array.new(@cols) { '-' } }
    end

    def to_s
      ret = " \tABCDEFGH\n"
      (0..(@rows - 1)).each do |row|
        ret << "#{8 - row}\t"
        (0..(@cols - 1)).each do |col|
          ret << @board[row][col]
        end
        ret << "\n"
      end
      ret
    end
  end
end
