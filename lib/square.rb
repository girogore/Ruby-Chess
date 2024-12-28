require 'JSON'

module Chess
  PIECES = { empty: [nil, '-', ''],
             pawn_w: ['white', "\u2659", '♙'], knight_w: ['white', "\u2658", '♘'], bishop_w: ['white', "\u2657", '♗'],
             rook_w: ['white', "\u2656", '♖'], queen_w: ['white', "\u2655", '♕'], king_w: ['white', "\u2654", '♔'],
             pawn_b: ['black', "\u265F"], knight_b: ['black', "\u265E"], bishop_b: ['black', "\u265D"],
             rook_b: ['black', "\u265C"], queen_b: ['black', "\u265B"], king_b: ['black', "\u265A"] }.freeze
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

    def to_s
      PIECES[@piece][1]
    end
  end
end
