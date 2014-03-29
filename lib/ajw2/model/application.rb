require "erb"

module Ajw2::Model
  class Application
    attr_reader :source

    # Initializer
    # @param [Hash] source entire model description
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
      render_resource_include(:css)
    end

    # Generate Slim template which call external JavaScript
    # @return [Array] collection of generated code
    def render_js_include
      render_resource_include(:js)
    end

    # Return the list of local external files
    # @param [Symbol] type external file type, :css or :js
    # @param [Symbol] external_dir directory contains resource files
    # @return [Array] collection of external files (type == "file")
    def external_local_files(type, external_dir)
      raise ArgumentError unless [:css, :js].include? type
      @source[type].select { |f| not f[:remote] }.map { |f| File.expand_path(f[:src], external_dir) }
    end

    private

    def render_resource_include(type)
      raise "/application/#{type} is not found" unless @source[type]

      @source[type].inject([]) do |result, resource|
        src = resource[:remote] ? resource[:src] : "/#{type}/#{File.basename(resource[:src])}"
        result << send("#{type}_include", src)
      end.join("\n") + "\n"
    end

    def css_include(src)
      "link rel=\"stylesheet\" type=\"text/css\" href=\"#{src}\""
    end

    def js_include(src)
      "script src=\"#{src}\""
    end
  end
end
