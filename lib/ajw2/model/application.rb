require "erb"

module Ajw2::Model
  class Application
    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Application section must be a Hash" unless source.class == Hash
      @source = source
    end

    def render_header
      <<-EOS
meta charset="utf-8"
title
  | #{ERB::Util.html_escape(@source[:name])}
      EOS
    end
  end
end
