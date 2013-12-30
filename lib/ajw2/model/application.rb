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

    # Generate Slim template which call external CSS
    # @return [String] collection of generated code
    def render_css_include
      raise "/application/css is not found" unless @source[:css]

      @source[:css].inject([]) do |result, css|
        href = (css[:type] == "file") ? "/css/#{File.basename(css[:src])}" : css[:src]
        result << "link rel=\"stylesheet\" type=\"text/css\" href=\"#{href}\""
      end.join("\n") + "\n"
    end

    # Generate Slim template which call external JavaScript
    # @return [Array] collection of generated code
    def render_js_include
      raise "/application/js is not found" unless @source[:js]

      @source[:js].inject([]) do |result, js|
        src = (js[:type] == "file") ? "/js/#{File.basename(js[:src])}" : js[:src]
        result << "script src=\"#{src}\""
      end.join("\n") + "\n"
    end

    # Return the list of external files
    # @param [Symbol] type external file type, :css or :js
    # @return [Array] collection of external files (type == "file")
    def external_files(type)
      raise ArgumentError unless [:css, :js].include? type
      @source[type].select { |f| f[:type] == "file" }.map { |f| f[:src] }
    end
  end
end
