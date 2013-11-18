module Ajw2::Model
  class Interfaces
    INPUT_TYPE = %i{
      text password hidden search tel url email datetime date month week time
      datetime-local number range color checkbox radio file submit image reset
    }

    attr_reader :source

    def initialize(source)
      @source = source
    end

    def parse
      @source.inject("") { |result, el| result << parse_element(el, 0) }
    end

    private
    def parse_element(element, depth)
      raise ArgumentError unless element[:type] && element[:id]

      result = "  " * depth
      result << parse_type(element)
      result << parse_style(element) if element[:left] || element[:top] || element[:width]
      result << " #{element[:value]}" if element[:value]
      result << "\n"
      result << element[:children].inject("") do |res, el|
        res << parse_element(el, depth + 1)
      end if element[:children]

      result
    end

    def parse_type(element)
      if element[:type] == :panel
        result = "\##{element[:id]}"
      elsif INPUT_TYPE.include? element[:type]
        result = "input\##{element[:id]} type=\"#{element[:type]}\""
        result << " placeholder=\"#{element[:placeholder]}\"" if element[:placeholder]
      else
        result = "#{element[:type].to_s}\##{element[:id]}"
      end

      result
    end

    def parse_style(element)
      result = " style=\"position:absolute;"
      result << " left:#{element[:left]};" if element[:left]
      result << " top:#{element[:top]};" if element[:top]
      result << " width:#{element[:width]}px;" if element[:width]
      result << "\""
      result
    end
  end
end
