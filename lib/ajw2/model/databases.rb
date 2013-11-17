module Ajw2::Model
  class Databases
    attr_reader :source

    def initialize(source)
      @source = source
    end
  end
end
