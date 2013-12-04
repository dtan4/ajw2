require "active_support/inflector"

module Ajw2::Model
  class Events
    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Events section must be a Hash" unless source.class == Hash
      @source = source
    end

    def render_rb_ajax
      raise Exception unless @source[:events]

      @source[:events].inject([]) { |result, event| result << rb_ajax_event(event) } unless @source[:realtime]
    end

    def render_rb_realtime
      raise Exception unless @source[:events]

      @source[:events].inject([]) { |result, event| result << rb_realtime_event(event) } if @source[:realtime]
    end

    def render_js_ajax
      raise Exception unless @source[:events]

      @source[:events].inject([]) { |result, event| result << js_ajax_event(event) } unless @source[:realtime]
    end

    def render_js_realtime
      raise Exception unless @source[:events]

      @source[:events].inject([]) { |result, event| result << js_realtime_event(event) } if @source[:realtime]
    end

    private

    def rb_ajax_event(event)
      <<-EOS
post "/#{event[:id]}" do
  content_type :json
  response = {}
#{rb_params(event[:params], :ruby, 1)}
#{rb_ajax_action(event[:action])}
  response.to_json
end
      EOS
    end

    def rb_realtime_event(event)
    end

    def rb_params(params, type, indent)
      params.inject([]) do |result, param|
        result << "  " * indent + case type
                                  when :hash
                                    "#{param[:name]}: #{param[:name]}"
                                  when :response
                                    "response[:#{param[:name]}] = #{param[:name]}"
                                  else
                                    "#{param[:name]} = params[:#{param[:name]}]"
                                  end
      end.join("\n")
    end

    def rb_ajax_action(action)
      action[:type] == "conditional" ?
        rb_ajax_conditional(action) : rb_ajax_always(action)
    end

    def rb_ajax_conditional(action)

    end

    def rb_ajax_always(action)
      <<-EOS.chomp
#{rb_databases(action[:databases])}
#{rb_interfaces(action[:interfaces])}
EOS
    end

    def rb_databases(databases)
      databases.inject([]) do |result, database|
        result << rb_database(database)
      end.join("\n")
    end

    def rb_database(database)
      case database[:func]
      when "create" then rb_create(database)
      when "read" then rb_read(database)
      when "update" then rb_update(database)
      when "delete" then rb_delete(database)
      else
        raise Exception
      end
    end

    def rb_create(database)
      <<-EOS.chomp
  #{database[:id]} = #{database[:database].singularize.capitalize}.new(
#{rb_params(database[:params], :hash, 2)}
  )
  #{database[:id]}.save
      EOS
    end

    def rb_read(database)

    end

    def rb_update(database)

    end

    def rb_delete(database)

    end

    def rb_hash(params)

    end

    def rb_interfaces(interfaces)
      interfaces.inject([]) do |result, interface|
        result << rb_interface(interface)
      end.join("\n")
    end

    def rb_interface(interface)
      case interface[:func]
      when "signup"
      when "signin"
      when "setValue"
        rb_params(interface[:params], :response, 1)
      end
    end

    def js_get_element_value(value)
      case value[:func]
      when "getValue"
        "$('\##{value[:element]}').val();"
      else ""
      end
    end

    def js_params_js(params)
      params.inject([]) do |result, param|
        case param[:value][:type]
        when "element"
          result << "  var #{param[:name]} = #{js_get_element_value(param[:value])}"
        else
          raise "Undefined event value type!"
        end

      end.join("\n")
    end

    def js_params_json(params)
      params.inject([]) do |result, param|
        result << "'#{param[:name]}': #{param[:name]}"
      end.join(" ")
    end

    def js_trigger_function(type)
      case type
      when "onClick" then "click"
      else raise "Undefined trigger function!"
      end
    end

    def js_ajax_event(event)
      <<-EOS
$('\##{event[:target]}').#{js_trigger_function(event[:type])}(function() {
#{js_params_js(event[:params])}
  $.ajax({
    type: 'POST',
    url: '/#{event[:id]}',
    params: { #{js_params_json(event[:params])} },
    success: function(_xhr_msg) {
      var _xhr_json = JSON.parse(_xhr_msg);
#{js_success_func(event[:action][:interfaces][0])}
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
      EOS
    end

    def js_realtime_event(event)
      ""
    end

    def js_success_func(interface)
      result = ["      var #{interface[:id]} = _xhr_json['#{interface[:id]}'];"]

      case interface[:type]
      when "element"
        result << js_set_element_value(interface)
      else
        raise "Undefined interface action target type!"
      end

      result.join("\n")
    end

    def js_set_element_value(interface)
      raise "Too many parameters!" unless interface[:params].length == 1

      case interface[:func]
      when "setValue"
        "      $('\##{interface[:element]}').val(#{interface[:id]}['#{interface[:params][0][:name]}']);"
      else
        ""
      end
    end
  end
end
