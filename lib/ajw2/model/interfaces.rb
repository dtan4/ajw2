module Ajw2::Model
  class Interfaces
    INPUT_TYPE = %w{
      text password hidden search tel url email datetime date month week time
      datetime-local number range color checkbox radio file submit image reset
    }.map(&:to_sym)

    attr_reader :source

    def initialize(source)
      @source = source
    end

    def render
      @source.inject("") { |result, el| result << render_element(el, 0) }
    end

    private
    def render_element(element, depth)
      raise ArgumentError unless element[:type] && element[:id]

      result = "  " * depth
      result << render_type(element)
      result << render_style(element) if element[:left] || element[:top] || element[:width]
      result << " #{element[:value]}" if element[:value]
      result << "\n"
      result << element[:children].inject("") do |res, el|
        res << render_element(el, depth + 1)
      end if element[:children]

      result
    end

    def render_type(element)
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

    def render_style(element)
      result = " style=\"position:absolute;"
      result << " left:#{element[:left]};" if element[:left]
      result << " top:#{element[:top]};" if element[:top]
      result << " width:#{element[:width]}px;" if element[:width]
      result << "\""
      result
    end
  end
end
