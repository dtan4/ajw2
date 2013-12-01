require "erb"

module Ajw2::Model
  class Application
    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Application section must be a Hash" unless source.class == Hash
      @source = source
    end

    def render_header
      result = ["meta charset=\"utf-8\""]
      result << "title"
      result << "  | #{ERB::Util.html_escape(@source[:name])}"
      result.join("\n") << "\n"
    end
  end
end
