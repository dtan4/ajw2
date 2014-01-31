module Ajw2::Model
  # Generate source code from Interface model
  class Interface
    include Ajw2::Util

    INPUT_TYPE = %w{
      text password hidden search tel url email datetime date month week time
      datetime-local number range color checkbox radio file submit image reset
    }

    attr_reader :source

    # Initializer
    # @param [Hash] source entire model description
    def initialize(source)
      raise ArgumentError, "Interface section must be a Hash" unless source.class == Hash
      @source = source
    end

    # Generate Slim template
    # @return [Array] collection of generated code
    def render
      raise "/interface/elements is not found" unless @source[:elements]

      @source[:elements].inject([]) { |result, el| result << indent(render_element(el), 0) }.join("\n") + "\n"
    end

    private

    def escape(text)
      CGI.escapeHTML(text)
    end

    def render_element(element)
      raise ArgumentError unless element[:type] && element[:id]
      result = render_type(element)

      if element[:hidden]
        result << ' style="display: none"'
      end

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
        result = "#{render_class(element[:class])}#{render_id(element[:id])}"
      elsif INPUT_TYPE.include? element[:type]
        result = render_input_tag(element)
      else
        result = "#{element[:type].to_s}#{render_class(element[:class])}#{render_id(element[:id])}"
      end

      result
    end

    def render_id(element_id)
      "#" + escape(element_id)
    end

    def render_class(element_class)
      element_class ? "." + element_class.split(" ").join(".") :  ""
    end

    def render_attribute(attr, value)
      " #{attr}=\"#{escape(value)}\""
    end

    def render_input_tag(element)
      result = "input#{render_class(element[:class])}#{render_id(element[:id])}#{render_attribute("type", element[:type])}"
      result << render_attribute("placeholder", element[:placeholder]) if element[:placeholder]
      result
    end
  end
end
