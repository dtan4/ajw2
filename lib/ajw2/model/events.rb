require "active_support/inflector"
require "ajw2/model/event/javascript"
require "ajw2/model/event/ruby"

module Ajw2::Model
  class Events
    attr_reader :source

    def initialize(source, js = nil, rb = nil)
      raise ArgumentError, "Events section must be a Hash" unless source.class == Hash
      @source = source
      @js = js || Ajw2::Model::Event::JavaScript.new
      @rb = rb || Ajw2::Model::Event::Ruby.new
    end

    def render_rb_ajax
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @rb.render_ajax(event) unless event[:realtime]
        result
      end
    end

    def render_rb_realtime
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @rb.render_realtime(event) if event[:realtime]
        result
      end
    end

    def render_js_ajax
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.render_ajax(event) unless event[:realtime]
        result
      end
    end

    def render_js_realtime
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.render_realtime(event) if event[:realtime]
        result
      end
    end

    def render_js_onmessage
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << @js.render_onmessage(event) if event[:realtime]
        result
      end
    end
  end
end
