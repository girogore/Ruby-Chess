module Chess
  class Square
    attr_accessor :value, :owner

    def initialize
      @value = '-'
      @owner = nil
    end
  end
end
