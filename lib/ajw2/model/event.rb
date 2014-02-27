require "ajw2/model/event_renderer/javascript"
require "ajw2/model/event_renderer/ruby"

module Ajw2::Model
  # Generate source code from Events model
  class Event
    attr_reader :source

    # Initializer
    # @param [Hash] source entire model description
    # @param [Ajw2::Model::EventRenderer::JavaScript] js JavaScript code generator
    # @param [Ajw2::Model::EventRenderer::Ruby] rb Ruby code generator
    def initialize(source, js = nil, rb = nil)
      raise ArgumentError, "Event section must be a Hash" unless source.class == Hash
      @source = source
      @js = js || Ajw2::Model::EventRenderer::JavaScript.new
      @rb = rb || Ajw2::Model::EventRenderer::Ruby.new
    end

    # Generate Ruby code using Ajax
    # @return [Array] collection of generated code
    def render_rb_ajax
      render_rb(:ajax)
    end

    # Generate Ruby code using WebSocket
    # @return [Array] collection of generated code
    def render_rb_realtime
      render_rb(:realtime)
    end

    # Generate JavaScript code using Ajax
    # @return [Array] collection of generated code
    def render_js_ajax
      render_js(:ajax)
    end

    # Generate JavaScript code using WebSocket
    # @return [Array] collection of generated code
    def render_js_realtime
      render_js(:realtime)
    end

    # Generate JavaScript code which receives message via WebSocket
    # @return [Array] collection of generated code
    def render_js_onmessage
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.render_onmessage(event) if event[:type] == "realtime"
        result
      end
    end

    private

    def render_rb(type)
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @rb.send("render_#{type}", event) if event[:type] == type.to_s
        result
      end
    end

    def render_js(type)
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.send("render_#{type}", event) if event[:type] == type.to_s
        result
      end
    end
  end
end
