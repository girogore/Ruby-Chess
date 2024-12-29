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
        next if var == :@game_logic

        hash[var] = instance_variable_get var
      end
      hash.to_json
    end

    def from_json!(string)
      JSON.parse(string).each do |var, val|
        if var == '@board'
          @board = Board.new(val)
          @game_logic = GameLogic.new(@board.board)
        else
          instance_variable_set var, val
        end
      end
    end

    def playing?
      true
    end

    def load
      print "Enter filename of savefile.\n>>>>>> "
      begin
        file = gets.chomp
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
      if @board.board[start[0]][start[1]].owner != @current_player
        puts 'That is not your piece.'
        return false
      end
      if @board.board[target[0]][target[1]].owner == @current_player
        puts 'Destination is your own piece'
        return false
      end
      success = @game_logic.legal_move?(start, target)
      unless success
        puts 'That is not a legal move'
        return false
      end
      @board.move_piece(start, target)
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

    def process_turn
      success = false
      until success
        print "Player #{@current_player.capitalize}, enter your move (FROM) (TO), or PRINT or SAVE\n>>>>>> "
        input = gets.match(/[a-zA-Z1-8 ]+/)
        next if input.nil?

        input = input.to_s.gsub(' ', '') [0..4].upcase
        next unless input.length == 4 || input == 'PRINT'

        if input == 'SAVE'
          save
        elsif input == 'PRINT'
          puts '*****'
          puts self
        else
          # Turn input into move
          input = process_input(input)
          next if input.nil?

          start = input[0]
          target = input[1]
          success = move(start, target)
          puts 'Try again' unless success
        end
      end
      next_player
    end

    def next_player
      @current_player = @current_player == 'white' ? 'black' : 'white'
    end

    def to_s
      @board.to_s
    end
  end
end
