module Ajw2::Model
  class Events
    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Events section must be a Hash" unless source.class == Hash
      @source = source
    end
  end
end
