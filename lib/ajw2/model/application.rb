module Ajw2::Model
  class Application
    attr_reader :name

    def initialize(name)
      raise ArgumentError, "Application section must be a String" unless name.class == String
      @name = name
    end

    def render_header
      result = ["meta charset=\"utf-8\""]
      result << "title #{@name}"
      result.join("\n") << "\n"
    end
  end
end
