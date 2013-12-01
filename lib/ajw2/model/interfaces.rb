require "erb"

module Ajw2::Model
  class Interfaces
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
      raise Exception unless @source[:elements]

      @source[:elements].inject("") { |result, el| result << render_element(el, 0) }
    end

    private

    def escape(text)
      ERB::Util.html_escape(text)
    end

    def render_element(element, depth)
      raise ArgumentError unless element[:type] && element[:id]

      result = "  " * depth
      result << render_type(element)

      if element[:value]
        result << "\n"
        result << "  " * depth << "  | #{escape(element[:value])}"
      end

      result << "\n"
      result << element[:children].inject("") do |res, el|
        res << render_element(el, depth + 1)
      end if element[:children]

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
