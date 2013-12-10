require "erb"

module Ajw2::Model
  class Interfaces
    include Ajw2::Util

    INPUT_TYPE = %w{
      text password hidden search tel url email datetime date month week time
      datetime-local number range color checkbox radio file submit image reset
    }

    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Interfaces section must be a Hash" unless source.class == Hash
      @source = source
    end

    def render
      raise "/interfaces/elements is not found" unless @source[:elements]

      @source[:elements].inject([]) { |result, el| result << indent(render_element(el), 0) }.join("\n") + "\n"
    end

    private

    def escape(text)
      ERB::Util.html_escape(text)
    end

    def render_element(element)
      raise ArgumentError unless element[:type] && element[:id]
      result = render_type(element)

      if element[:value]
        result << "\n"
        result << "  | #{escape(element[:value])}"
      end

      result << "\n"
      result << element[:children].inject([]) do |res, el|
        res << indent(render_element(el), 1)
      end.join("\n") if element[:children]

      result
    end

    def render_type(element)
      if element[:type] == "panel"
        result = "\##{escape(element[:id])}"
      elsif INPUT_TYPE.include? element[:type]
        result = "input\##{element[:id]} type=\"#{element[:type]}\""
        result << " placeholder=\"#{escape(element[:placeholder])}\"" if element[:placeholder]
      else
        result = "#{element[:type].to_s}\##{element[:id]}"
      end

      result
    end
  end
end
