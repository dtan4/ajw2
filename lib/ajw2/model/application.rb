require "erb"

module Ajw2::Model
  class Application
    attr_reader :source

    # Initializer
    # @param [Hash] source entire model descriptionx
    def initialize(source)
      raise ArgumentError, "Application section must be a Hash" unless source.class == Hash
      @source = source
    end

    # Generate Slim template of HTML header
    # @return [String] Slim template
    def render_header
      <<-EOS
meta charset="utf-8"
title
  | #{ERB::Util.html_escape(@source[:name])}
      EOS
    end

    # Generate Slim template which call external CSS file
    # @return [String] collection of generated code
    def render_css_include
      @source[:css].inject([]) do |result, css|
        result << "link rel=\"stylesheet\" type=\"text/css\" href=\"/css/ext/#{File.basename(css)}\""
      end.join("\n") + "\n"
    end

    # Generate Slim template which call external JavaScript file
    # @return [Array] collection of generated code
    def render_js_include
      @source[:js].inject([]) do |result, js|
        result << "script src=\"/js/ext/#{File.basename(js)}\""
      end.join("\n") + "\n"
    end
  end
end
