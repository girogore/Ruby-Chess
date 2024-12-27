require_relative 'board'
require 'JSON'

module Chess
  class Game
    def initialize
      success = false
      until success
        # ask to load?
        print "Load game? Y/N \n>>>>>> "
        ## for quicker testing
        input = gets[0].upcase
        # puts
        # input = 'N'
        ##
        if input == 'Y'
          success = load
        else
          @board = Board.new
          @current_player = 'white'
          @current_turn = 1
          success = true
        end
      end
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
        if var == '@board'
          @board = Board.new(val)
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
        # file = 'save1'
        from_json!(File.read(file))
        true
      rescue StandardError
        puts 'Failed to load file'
        false
      end
    end

    def save
      print "Enter filename to save game to.\n>>>>>> "
      file = gets.chomp
      # file = 'save1'
      begin
        File.open(file, 'w') { |f| f.print(to_json) }
        true
      rescue StandardError
        puts 'Failed to save to file'
        false
      end
    end

    def process_turn
      success = false
      until success
        print "Player #{@current_player.capitalize}, enter your move, or type SAVE\n>>>>>> "
        input = gets.chomp.upcase
        if input == 'SAVE'
          save
        else
          # Turn input into move
          success = true
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
