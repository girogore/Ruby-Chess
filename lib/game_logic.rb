require_relative 'board'

module Chess
  class GameLogic
    def initialize(board)
      @board = board
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

    def collision?(start, target)
      range = [target[0] < start[0] ? (target[0] + 1...start[0]) : (start[0] + 1...target[0]),
               target[1] < start[1] ? (target[1] + 1...start[1]) : (start[1] + 1...target[1])]

      if start[0] == target[0] # horizontal move
        range[1].each { |col| return true if @board[start[0]][col].piece != :empty }
      elsif start[1] == target[1] # vertical move
        range[0].each { |row| return true if @board[row][start[1]].piece != :empty }
      else # diagonal move
        range[0].each_with_index { |col, index| return true if @board[col][range[1].to_a[index]].piece != :empty }
      end
      false
    end

    def try_move_pawn?(start, target)
      owner = @board[start[0]][start[1]].owner
      distance = owner == 'white' ? target[0] - start[0] : start[0] - target[0]
      return false if distance > 2 || distance <= 0 || (target[1] - start[1]).abs > 1

      if distance.abs == 2
        # Pawns first move only
        return false if collision?(start, target)
        return false if owner == 'white' && start[0] != 1
        return false if owner == 'black' && start[0] != 6

        @board[target[0]][target[1]].owner == :empty
      elsif (target[1] - start[1]).abs == 1
        # TODO: Check for en passent somehow..
        @board[target[0]][target[1]].owner == (owner == 'white' ? 'black' : 'white')
      else
        # Move one square up
        @board[target[0]][target[1]].owner == :empty
      end
    end

    def try_move_rook?(start, target)
      return false if start[0] != target[0] && start[1] != target[1] # non-straight line

      !collision?(start, target)
    end

    def try_move_knight?(start, target)
      return false if start[0] == target[0] || start[1] == target[1] # straight line

      (start[0] - target[0]).abs + (start[1] - target[1]).abs == 3
    end

    def try_move_bishop?(start, target)
      return false unless (start[0] - target[0]).abs == (start[1] - target[1]).abs

      !collision?(start, target)
    end

    def try_move_queen?(start, target)
      if (start[0] - target[0]).abs != (start[1] - target[1].abs) || (start[0] == target[0]) || (start[1] == target[1])
        false
      end
      !collision?(start, target)
    end

    def try_move_king?(start, target)
      # TODO: Check for castling

      distance = (start[0] - target[0]).abs + (start[1] - target[1]).abs
      return distance == 1 if (start[0] == target[0]) || (start[1] == target[1])

      distance == 2
    end

    def legal_move?(start, target)
      case @board[start[0]][start[1]].piece
      when :pawn_w, :pawn_b
        try_move_pawn?(start, target)
      when :rook_w, :rook_b
        try_move_rook?(start, target)
      when :knight_w, :knight_b
        try_move_knight?(start, target)
      when :bishop_w, :bishop_b
        try_move_bishop?(start, target)
      when :queen_w, :queen_b
        try_move_queen?(start, target)
      when :king_w, :king_b
        try_move_king?(start, target)
      end
    end
  end
end
