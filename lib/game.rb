require_relative 'board'
require 'JSON'

module Chess
  class Game
    def initialize(file = nil)
      if file.nil?
        @board = Board.new
        @current_player = 'White'
        @current_turn = 1
      else
        load
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
        instance_variable_set var, val
      end
    end

    def playing?
      true
    end

    def load
      print "Enter filename to save game to.\n>>>>>> "
      begin
        file = gets.chomp
        from_json!(File.read(file))
        true
      rescue StandardError
        puts 'Failed to load file'
        false
      end
    end

    def save
      print "Enter filename of savefile.\n>>>>>> "
      file = gets.chomp
      begin
        File.open(file, 'w') { |f| f.print(to_json) }
        true
      rescue StandardError
        puts 'Failed to save to file'
        false
      end
    end

    def process_turn
      print "Player #{@current_player}, enter your move, or type SAVE\n>>>>>> "
      input = gets.upcase
      if input == 'SAVE'
        save
      else
        # Turn input into move
      end
    end

    def to_s
      @board.to_s
    end
  end
end
