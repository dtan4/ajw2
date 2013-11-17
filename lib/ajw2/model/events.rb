module Ajw2::Model
  class Events
    attr_reader :source

    def initialize(source)
      @source = source
    end
  end
end
