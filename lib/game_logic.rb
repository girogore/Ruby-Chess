require_relative 'game'

module Chess
  # Handles all chess logic for the board
  class GameLogic
    attr_accessor :previous_move, :board, :castle_allowed

    def initialize(board)
      return if board.nil?

      @board = board
      @previous_move = nil
      @rows = @board.length
      @cols = @board[0].length
      @castle_allowed = [[true, true], [true, true]] # White [left, right] Black [left, right]
    end

    def to_json(*_args)
      hash = {}
      instance_variables.each do |var|
        next if var == :@board

        hash[var] = instance_variable_get var
      end
      hash.to_json
    end

    def from_json!(string)
      string.each do |var, val|
        instance_variable_set var, val
      end
    end

    # Side = :left, :right, :both
    def castle_used(player, side)
      player_index = player == 'white' ? 0 : 1
      case side
      when :left
        castle_allowed[player_index][0] = false
      when :right
        castle_allowed[player_index][1] = false
      when :both
        castle_allowed[player_index][0] = false
        castle_allowed[player_index][1] = false
      end
    end

    def collision?(start, target, board = @board)
      range = [target[0] < start[0] ? (target[0] + 1...start[0]).to_a : (start[0] + 1...target[0]).to_a.reverse,
               target[1] < start[1] ? (target[1] + 1...start[1]).to_a : (start[1] + 1...target[1]).to_a.reverse]

      if start[0] == target[0] # horizontal move
        range[1].each { |col| return true if board[start[0]][col].piece != :empty }
      elsif start[1] == target[1] # vertical move
        range[0].each { |row| return true if board[row][start[1]].piece != :empty }
      else # diagonal move
        range[0].each_with_index { |col, index| return true if board[col][range[1][index]].piece != :empty }
      end
      false
    end

    def legal_move?(start, target, board = @board)
      reach = piece_movement_reach(start, board)
      success = reach.include?(target)
      if success == false
        puts "#{board[start[0]][start[1]].proper_name} does not move that way"
        return false
      end
      true
    end

    def pawn_attack_reach(location, board = @board)
      owner = board[location[0]][location[1]].owner
      opponent = Game.opponent(owner)
      ret = []
      if owner == 'white'
        return ret if location[0] >= @rows - 1

        if location[1] != 0 && board[location[0] + 1][location[1] - 1].owner == opponent
          ret << [location[0] + 1, location[1] - 1]
        end
        if location[1] != @cols - 1 && board[location[0] + 1][location[1] + 1].owner == opponent
          ret << [location[0] + 1, location[1] + 1]
        end
      elsif owner == 'black'
        return ret if location[0].zero?

        if location[1] != 0 && board[location[0] - 1][location[1] - 1].owner == opponent
          ret << [location[0] - 1, location[1] - 1]
        end
        if location[1] != @cols - 1 && board[location[0] - 1][location[1] + 1].owner == opponent
          ret << [location[0] - 1, location[1] + 1]
        end
      end

      # En passant
      unless previous_move.nil?
        start = previous_move[0]
        target = previous_move[1]
        # if previous move was an adjacent pawn that moved forward twice
        if target[0] == location[0] && (location[1] - target[1]).abs == 1 &&
           %i[pawn_w pawn_b].include?(board[target[0]][target[1]].piece) &&
           start[1] == target[1] && (start[0] - target[0]).abs == 2
          ret << [target[0] + (owner == 'white' ? 1 : -1), target[1]]
        end
      end
      ret
    end

    def pawn_move_reach(location, board = @board)
      owner = board[location[0]][location[1]].owner
      ret = []
      if owner == 'white'
        two_up = [location[0] + 2, location[1]]
        if location[0] < @rows - 1 && board[location[0] + 1][location[1]].owner == (:empty)
          ret << [location[0] + 1, location[1]]
        end
        if location[0] == 1 && (!collision?(location, two_up, board) && board[two_up[0]][two_up[1]].owner == (:empty))
          ret << two_up
        end
      elsif owner == 'black'
        two_down = [location[0] - 2, location[1]]
        if location[0] >= 1 && board[location[0] - 1][location[1]].owner == (:empty)
          ret << [location[0] - 1, location[1]]
        end
        if location[0] == 6 && (!collision?(location, two_down,
                                            board) && board[two_down[0]][two_down[1]].owner == (:empty))
          ret << two_down
        end
      end
      ret
    end

    def rook_movement_reach(location, board = @board, range = @rows - 1)
      owner = board[location[0]][location[1]].owner
      ret = []
      vert_array = (location[0] + 1..location[0] + range).to_a.concat((location[0] - range...location[0]).to_a.reverse)
      horz_array = (location[1] + 1..location[1] + range).to_a.concat((location[1] - range...location[1]).to_a.reverse)
      vert_array.each do |row|
        next unless row >= 0 && row < @rows && location[1] >= 0 && location[1] < @cols
        next if collision?(location, [row, location[1]], board) || board[row][location[1]].owner == owner

        ret << [row, location[1]]
      end
      horz_array.each do |col|
        next unless location[0] >= 0 && location[0] < @rows && col >= 0 && col < @cols
        next if collision?(location, [location[0], col], board) || board[location[0]][col].owner == owner

        ret << [location[0], col]
      end
      ret
    end

    def knight_movement_reach(location, board = @board)
      owner = board[location[0]][location[1]].owner
      ret = []
      l_shapes = [[2, -1], [2, 1], [1, -2], [1, 2], [-1, -2], [-1, 2], [-2, -1], [-2, 1]]
      l_shapes.each do |move|
        target = [location[0] + move[0], location[1] + move[1]]
        if target[0] >= 0 && target[0] < @rows && target[1] >= 0 && target[1] < @cols && board[target[0]][target[1]].owner != (owner)
          ret << target
        end
      end
      ret
    end

    def bishop_movement_reach(location, board = @board, range = @rows - 1)
      owner = board[location[0]][location[1]].owner
      ret = []
      (0..range).each do |idx|
        change_options = [[location[0] + idx, location[1] + idx], [location[0] + idx, location[1] - idx],
                          [location[0] - idx, location[1] - idx], [location[0] - idx, location[1] + idx]]
        change_options.each do |change|
          if (change[0] >= 0 && change[0] < @rows && change[1] >= 0 && change[1] < @cols) && # Not off the board
             (!collision?(location, change, board) && board[change[0]][change[1]].owner != owner) # Nothing in the way
            ret << change
          end
        end
      end
      ret
    end

    def queen_movement_reach(location, board = @board)
      bishop_movement_reach(location, board).concat(rook_movement_reach(location, board))
    end

    def king_movement_reach(location, board = @board)
      owner = board[location[0]][location[1]].owner
      ret = bishop_movement_reach(location, board, 1).concat(rook_movement_reach(location, board, 1))
      # checking for allowed castle
      return ret if check?(owner, board) # Cant castle while in check

      row = owner == 'white' ? 0 : 7
      if @castle_allowed[owner == 'white' ? 0 : 1][0] &&
         !collision?(location, [row, 0], board) && board[row][0].piece == (owner == 'white' ? :rook_w : :rook_b)
        safe_move = true
        [[row, 3], [row, 2]].each { |square| safe_move = false if under_attack?(square, owner, board) }
        ret << [row, 2] if safe_move
      end
      if @castle_allowed[owner == 'white' ? 0 : 1][1] &&
         !collision?(location, [row, 7], board) && board[row][7].piece == (owner == 'white' ? :rook_w : :rook_b)
        safe_move = true
        [[row, 5], [row, 6]].each { |square| safe_move = false if under_attack?(square, owner, board) }
        ret << [row, 6] if safe_move
      end
      ret
    end

    # returns an array of all the x,y pairs the piece can attack
    def piece_attack_reach(location, board = @board)
      case board[location[0]][location[1]].piece
      when :pawn_w, :pawn_b
        pawn_attack_reach(location, board)
      when :rook_w, :rook_b
        rook_movement_reach(location, board)
      when :knight_w, :knight_b
        knight_movement_reach(location, board)
      when :bishop_w, :bishop_b
        bishop_movement_reach(location, board)
      when :queen_w, :queen_b
        queen_movement_reach(location, board)
      when :king_w, :king_b
        king_movement_reach(location, board)
      end
    end

    def move_piece_array(start, target, board)
      piece = board[start[0]][start[1]].piece
      board[start[0]][ start[1]].piece = :empty
      board[target[0]][ target[1]].piece = piece
    end

    # Returns an array of all the x,y pairs the piece can reach
    def piece_movement_reach(location, board = @board)
      owner = board[location[0]][location[1]].owner
      piece = board[location[0]][location[1]].piece
      test_ret = if %i[pawn_w pawn_b].include?(piece)
                   pawn_move_reach(location, board).concat(pawn_attack_reach(location, board))
                 else
                   piece_attack_reach(location, board)
                 end
      ret = []
      # Moves that put you in check are not allowed
      return [] if test_ret.nil? || test_ret.empty?

      test_ret.each do |test_move|
        check_board = Marshal.load(Marshal.dump(board))
        move_piece_array(location, test_move, check_board)
        ret << test_move unless check?(owner, check_board)
      end
      ret
    end

    def under_attack?(location, attacked_player, board = @board)
      # Check every opponent piece and see if they can attack the indicated square
      (0..@rows - 1).each do |row|
        (0..@cols - 1).each do |col|
          next unless board[row][col].owner == Game.opponent(attacked_player)
          next if %i[king_b king_w].include?(board[row][col].piece)

          reach = piece_attack_reach([row, col], board)
          next if reach.nil?
          return true if reach.include?(location)
        end
      end
      false
    end

    def check?(player, board = @board)
      # Locate King, check if it is under attack
      king = []
      catch :FoundKing do
        (0..(@rows - 1)).each do |row|
          (0..(@cols - 1)).each do |col|
            if (board[row][col].piece == :king_b || board[row][col].piece == :king_w) && board[row][col].owner == (player)
              king = [row, col]
              throw :FoundKing
            end
          end
        end
      end
      under_attack?(king, player, board)
    end

    def checkmate?(player, board = @board)
      (0..@rows - 1).each do |row|
        (0..@cols - 1).each do |col|
          next unless board[row][col].owner == player

          reach = piece_movement_reach([row, col], board) # If player has a move, they aren't in checkmate
          return false unless reach.nil? || reach.empty?
        end
      end
      true
    end
  end
end
