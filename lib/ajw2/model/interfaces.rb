module Ajw2::Model
  class Interfaces
    attr_reader :source

    def initialize(source)
      @source = source
    end

    def parse
      @source.inject("") { |result, el| result << parse_element(el, 0) }
    end

    private
    def parse_element(element, depth)
      result = "  " * depth

      if element[:type] == :panel
        result << "\##{element[:id]}"
      elsif %i{text password}.include? element[:type]
        result << "input\##{element[:id]}"
        result << " type=\"#{element[:type]}\""
        result << " placeholder=\"#{element[:placeholder]}\"" if element[:placeholder]
      else
        result << "#{element[:type].to_s}\##{element[:id]}"
      end

      result << parse_style(element) if element[:left] || element[:top] || element[:width]

      result << " #{element[:value]}" if element[:value]
      result << "\n"
      result << element[:children].inject("") do |result, el|
        result << parse_element(el, depth + 1)
      end if element[:children]
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
