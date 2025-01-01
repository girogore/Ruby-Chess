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

    # Assigns the space at specified row,col to piece, does no logic checks
    def assign_space(row, col, piece)
      @board[row][col].piece = piece
    end

    def promotion(player)
      row = player == 'white' ? @cols - 1 : 0
      board[row].each_with_index do |piece, idx|
        next unless %i[pawn_b pawn_w].include?(piece.piece)

        print "Promote your #{('A'.ord + idx).chr} pawn\n>>>>>> "
        success = false
        until success
          input = gets.chomp.downcase
          case input
          when 'queen'
            assign_space(row, idx, player == 'white' ? :queen_w : :queen_b)
            success = true
          when 'rook'
            assign_space(row, idx, player == 'white' ? :rook_w : :rook_b)
            success = true
          when 'bishop'
            assign_space(row, idx, player == 'white' ? :bishop_w : :bishop_b)
            success = true
          when 'knight'
            assign_space(row, idx, player == 'white' ? :knight_w : :knight_b)
            success = true
          else
            puts 'Please choose 1 of the following: queen, rook, bishop, knight'
          end
        end
      end
    end

    # Moves piece at start->target, does no logic checks
    def move_piece(start, target)
      piece = @board[start[0]][start[1]].piece
      owner = @board[start[0]][start[1]].owner
      assign_space(start[0], start[1], :empty)
      assign_space(target[0], target[1], piece)
      # Castle?
      row = owner == 'white' ? 0 : 7
      return unless %i[king_b king_w].include?(piece) || start == [row, 4]

      move_piece([row, 0], [row, 3]) if target == [row, 2] # Long castle
      move_piece([row, 7], [row, 5]) if target[1] == [row, 6] # Kingside Castle
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
      ret = "   A B C D E F G H\n#{LINE}\n" # Column label (Letter Format)
      # ret = "   0 1 2 3 4 5 6 7\n#{LINE}\n"
      (@rows - 1).downto(0) do |row|
        # ret << "#{row} |"
        ret << "#{row + 1} |" # Row Label (offset)
        (0..(@cols - 1)).each do |col|
          ret << @board[row][col].to_s.encode('utf-8') << '|'
        end
        ret << "\n#{LINE}\n"
      end
      ret
    end
  end
end
