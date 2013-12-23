require "active_support/inflector"
require "ajw2/model/event/javascript"
require "ajw2/model/event/ruby"

module Ajw2::Model
  # Generate source code from Events model
  class Events
    attr_reader :source

    # Initializer
    # @param [Hash] source entire model description
    # @param [Ajw2::Model::Event::JavaScript] js JavaScript code generator
    # @param [Ajw2::Model::Event::Ruby] rb Ruby code generator
    def initialize(source, js = nil, rb = nil)
      raise ArgumentError, "Events section must be a Hash" unless source.class == Hash
      @source = source
      @js = js || Ajw2::Model::Event::JavaScript.new
      @rb = rb || Ajw2::Model::Event::Ruby.new
    end

    # Generate Ruby code using Ajax
    # @return [Array] collection of generated code
    def render_rb_ajax
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @rb.render_ajax(event) unless event[:realtime]
        result
      end
    end

    # Generate Ruby code using WebSocket
    # @return [Array] collection of generated code
    def render_rb_realtime
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @rb.render_realtime(event) if event[:realtime]
        result
      end
    end

    # Generate JavaScript code using Ajax
    # @return [Array] collection of generated code
    def render_js_ajax
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.render_ajax(event) unless event[:realtime]
        result
      end
    end

    # Generate JavaScript code using WebSocket
    # @return [Array] collection of generated code
    def render_js_realtime
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.render_realtime(event) if event[:realtime]
        result
      end
    end

    # Generate JavaScript code which receives message via WebSocket
    # @return [Array] collection of generated code
    def render_js_onmessage
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.render_onmessage(event) if event[:realtime]
        result
      end
    end
  end
end
