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
      raise "/application/name is not found" unless @source[:name]

      <<-EOS
meta charset="utf-8"
title
  | #{ERB::Util.html_escape(@source[:name])}
      EOS
    end

    # Generate Slim template which call external CSS file
    # @return [String] collection of generated code
    def render_css_include
      raise "/application/css is not found" unless @source[:css]

      @source[:css].inject([]) do |result, css|
        result << "link rel=\"stylesheet\" type=\"text/css\" href=\"/css/ext/#{File.basename(css)}\""
      end.join("\n") + "\n"
    end

    # Generate Slim template which call external JavaScript file
    # @return [Array] collection of generated code
    def render_js_include
      raise "/application/js is not found" unless @source[:js]

      @source[:js].inject([]) do |result, js|
        result << "script src=\"/js/ext/#{File.basename(js)}\""
      end.join("\n") + "\n"
    end

    def external_files(type)
      raise ArgumentError unless [:css, :js].include? type
      @source[type]
    end
  end
end
