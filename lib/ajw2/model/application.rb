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
        href = css[:remote] ? css[:src] : "/css/#{File.basename(css[:src])}"
        result << "link rel=\"stylesheet\" type=\"text/css\" href=\"#{href}\""
      end.join("\n") + "\n"
    end

    # Generate Slim template which call external JavaScript
    # @return [Array] collection of generated code
    def render_js_include
      raise "/application/js is not found" unless @source[:js]

      @source[:js].inject([]) do |result, js|
        src = js[:remote] ?  js[:src] : "/js/#{File.basename(js[:src])}"
        result << "script src=\"#{src}\""
      end.join("\n") + "\n"
    end

    # Return the list of local external files
    # @param [Symbol] type external file type, :css or :js
    # @param [Symbol] external_dir directory contains resource files
    # @return [Array] collection of external files (type == "file")
    def external_local_files(type, external_dir)
      raise ArgumentError unless [:css, :js].include? type
      @source[type].select { |f| not f[:remote] }.map { |f| File.expand_path(f[:src], external_dir) }
    end
  end
end
