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
        @board = Array.new(@rows) { Array.new(@cols) { Square.new(:empty) } }
        initial_state
      else
        @board = Array.new(@rows) { Array.new(@cols) }
        json_board = json['@board']
        (0..@cols - 1).each do |col|
          (0..@rows - 1).each do |row|
            @board[row][col] = Square.new(json_board[row][col]['@piece'].to_sym)
          end
        end
      end
    end

    def initial_state
      %i[rook_w knight_w bishop_w queen_w king_w bishop_w knight_w rook_w].each_with_index do |space, index|
        @board[0][index].piece = space
      end
      board[1].each { |space| space.piece = :pawn_w }

      %i[rook_b knight_b bishop_b queen_b king_b bishop_b knight_b rook_b].each_with_index do |space, index|
        @board[@rows - 1][index].piece = space
      end
      board[@rows - 2].each { |space| space.piece = :pawn_b }
    end

    def assign_space(row, col, piece)
      @board[row][col].piece = piece
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

      (@rows - 1).downto(0) do |row|
        ret << "#{row + 1} |"
        (0..(@cols - 1)).each do |col|
          ret << @board[row][col].to_s.encode('utf-8') << '|'
        end
        ret << "\n#{LINE}\n"
      end
      ret
    end
  end
end
