module Ajw2::Model
  class Events
    attr_reader :source

    def initialize(source)
      raise Exception unless source.class == Hash
      @source = source
    end
  end
end
