require 'JSON'

module Chess
  PIECES = { empty: [:empty, '-', '', 'Empty Space'],
             pawn_w: ['white', "\u2659", '♙', 'White Pawn'], knight_w: ['white', "\u2658", '♘', 'White Knight'],
             bishop_w: ['white', "\u2657", '♗', 'White Bishop'], rook_w: ['white', "\u2656", '♖', 'White Rook'],
             queen_w: ['white', "\u2655", '♕', 'White Queen'], king_w: ['white', "\u2654", '♔', 'White King'],
             pawn_b: ['black', "\u265F", '♟', 'Black Pawn'], knight_b: ['black', "\u265E", '♞', 'Black Knight'],
             bishop_b: ['black', "\u265D", '♝', 'Black Bishop'], rook_b: ['black', "\u265C", '♜', 'Black Rook'],
             queen_b: ['black', "\u265B", '♛', 'Black Queen'], king_b: ['black', "\u265A", '♚', 'Black King'] }.freeze
  # Squares contain a single element #piece , containing the symbol for the piece
  class Square
    attr_accessor :piece

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

    def initialize(piece)
      @piece = piece
    end

    def owner
      PIECES[@piece][0]
    end

    def proper_name
      PIECES[@piece][3]
    end

    def to_s
      PIECES[@piece][1]
    end
  end
end
