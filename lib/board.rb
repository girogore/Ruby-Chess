require_relative 'square'
require 'JSON'

module Chess
  # Contains information for a chess board
  class Board
    attr_accessor :rows, :cols, :board

    LINE = '  |---------------|'.freeze

    def initialize(json = nil)
      @rows = 8
      @cols = 8
      if json.nil?
        @board = Array.new(@rows) { Array.new(@cols) { Square.new('-', nil) } }
        (0..@cols - 1).each do |col|
          set_space(col, 2, :pawn_w)
        end
      else
        @board = Array.new(@rows) { Array.new(@cols) }
        json_board = json['@board']
        (0..@cols - 1).each do |col|
          (0..@rows - 1).each do |row|
            @board[row][col] = Square.new(json_board[row][col]['@piece'], json_board[row][col]['@owner'])
          end
        end
      end
    end

    def set_space(row, col, piece)
      @board[row][col].owner = PIECES[piece][0]
      @board[row][col].piece = PIECES[piece][1]
    end

    def to_json(*_args)
      hash = {}
      instance_variables.each do |var|
        hash[var] = instance_variable_get var
      end
      hash.to_json
    end

    def from_json!(string)
      JSON.parse(string).each do |var, val|
        instance_variable_set var, val
      end
    end

    def to_s
      ret = "   A B C D E F G H\n#{LINE}\n"

      (0..(@rows - 1)).each do |row|
        ret << "#{row} |"
        (0..(@cols - 1)).each do |col|
          ret << @board[row][col].piece.encode('utf-8') << '|'
        end
        ret << "\n#{LINE}\n"
      end
      ret
    end
  end
end
