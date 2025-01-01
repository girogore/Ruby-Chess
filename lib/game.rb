require_relative 'board'
require_relative 'game_logic'
require 'JSON'
require 'pathname'

module Chess
  # Contains and runs the Chess game
  class Game
    attr_reader :board, :current_turn, :current_player, :game_logic

    def initialize
      @board = nil
      @current_player = 'white'
      @current_turn = 1
      @game_logic = nil
    end

    def self.opponent(player)
      return nil if player == :empty

      player == 'white' ? 'black' : 'white'
    end

    def start_game(ask: true)
      success = false
      until success
        # ask to load?
        if ask
          print "Load game? Y/N \n>>>>>> "
          input = gets[0].upcase
          puts
        end
        if input == 'Y'
          success = load
        else
          @board = Board.new
          @game_logic = GameLogic.new(@board.board)
          @current_player = 'white'
          @current_turn = 1
          success = true
        end
      end
    end

    def to_json(*_args)
      hash = {}
      instance_variables.each do |var|
        # next if var == :@game_logic

        hash[var] = instance_variable_get var
      end
      hash.to_json
    end

    def from_json!(string)
      JSON.parse(string).each do |var, val|
        @game_logic = GameLogic.new(nil)
        case var
        when '@board'
          @board = Board.new(val)
        when '@game_logic'
          @game_logic.from_json!(val)
        else
          instance_variable_set var, val
        end
      end
      @game_logic.board = @board.board
    end

    def playing?
      !@game_logic.checkmate?(current_player, @board.board)
    end

    def load(input_file = nil)
      if input_file.nil?
        print "Enter filename of savefile.\n>>>>>> "
        file = gets.chomp
      else
        file = input_file
      end
      begin
        path = Pathname.new(file)
        from_json!(File.read(path))
        true
      rescue StandardError
        puts 'Failed to load file'
        false
      end
    end

    def save(input_file = nil)
      if input_file.nil?
        print "Enter filename to save game to.\n>>>>>> "
        file = gets.chomp
      else
        file = input_file
      end
      begin
        path = Pathname.new(file)
        FileUtils.mkdir_p(path.dirname)
        File.open(path, 'w') { |f| f.print(to_json) }
        true
      rescue StandardError
        puts 'Failed to save to file'
        false
      end
    end

    def move(start, target)
      if start == target
        puts 'Start and Destination are the same'
        return false
      end
      if @board.board[start[0]][start[1]].piece == :empty
        puts 'That space is empty.'
        return false
      end
      piece = @board.board[start[0]][start[1]].piece
      owner = @board.board[start[0]][start[1]].owner
      if owner != @current_player
        puts 'That is not your piece.'
        return false
      end
      if @board.board[target[0]][target[1]].owner == @current_player
        puts 'Destination is your own piece'
        return false
      end
      success = @game_logic.legal_move?(start, target)
      return false unless success

      @board.move_piece(start, target)
      game_logic.castle_used(owner, :both) if %i[king_b king_w].include?(piece)
      if %i[rook_b rook_w].include?(piece)
        game_logic.castle_used(owner, :left) if start[0].zero?
        game_logic.castle_used(owner, :right) if start[0] == 7
      end
      true
    end

    def process_input(input)
      start = input[0..1].chars.sort.join.match(/[1-8][A-H]/)
      target = input[2..3].chars.sort.join.match(/[1-8][A-H]/)
      if start.nil? || target.nil?
        puts 'Enter a move using the coordinates on the board'
        return nil
      end
      s_start = start.to_s
      s_target = target.to_s
      start = [s_start[0].to_i - 1, s_start[1].ord - 'A'.ord]
      target = [s_target[0].to_i - 1, s_target[1].ord - 'A'.ord]
      [start, target]
    end

    def process_turn(force_move = nil)
      success = false
      until success
        if force_move.nil?
          print "Player #{@current_player.capitalize}, enter your move (FROM) (TO), or PRINT or SAVE\n>>>>>> "
          input = gets.match(/[a-zA-Z1-8 ]+/)
          next if input.nil?

          input = input.to_s.gsub(' ', '') [0..4].upcase
          next unless input.length == 4 || input == 'PRINT'
        else
          input = force_move
          input = input.match(/[a-zA-Z1-8 ]+/).to_s.gsub(' ', '') [0..4].upcase
          force_move = nil
        end
        if input == 'SAVE'
          save
        elsif input == 'PRINT'
          puts self
        else
          # Turn input into move
          input = process_input(input)
          next if input.nil?

          start = input[0]
          target = input[1]
          puts "Moving #{@board.board[start[0]][start[1]].proper_name}..."
          success = move(start, target)
          puts 'Try again' unless success
        end
      end
      @board.promotion(current_player)
      @game_logic.previous_move = [start, target]
      next_player
    end

    def who_won
      check = @game_logic.check?(current_player)
      # Checkmate / Draw check -- similar but one requires the player to be in check
      return :draw unless check

      Game.opponent(current_player)
    end

    def next_player
      @current_player = Game.opponent(current_player)
    end

    def to_s
      @board.to_s
    end
  end
end
