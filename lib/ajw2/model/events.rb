require "active_support/inflector"

module Ajw2::Model
  class Events
    include Ajw2

    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Events section must be a Hash" unless source.class == Hash
      @source = source
    end

    def render_rb_ajax
      raise Exception unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << rb_ajax_event(event) unless event[:realtime]
        result
      end
    end

    def render_rb_realtime
      raise Exception unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << rb_realtime_event(event) if event[:realtime]
        result
      end
    end

    def render_js_ajax
      raise Exception unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << js_ajax_event(event) unless event[:realtime]
        result
      end
    end

    def render_js_realtime
      raise Exception unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << js_realtime_event(event) if event[:realtime]
        result
      end
    end

    def render_js_onmessage
      raise Exception unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << js_onmessage(event) if event[:realtime]
        result
      end
    end

    private

    def rb_ajax_event(event)
      <<-EOS
post "/#{event[:id]}" do
  content_type :json
  response = {}
#{indent(rb_params(event[:params], :ruby, 1), 1)}
#{indent(rb_action(event[:action]), 1)}
  response.to_json
end
      EOS
    end

    def rb_realtime_event(event)
      <<-EOS
when "#{event[:id]}"
#{indent(rb_params(event[:params], :ruby, 1), 1)}
#{indent(rb_action(event[:action]), 1)}
  EventMachine.next_tick do
    settings.sockets.each { |s| s.send(response.to_json) }
  end
      EOS
    end

    def rb_params(params, type, indent)
      params.inject([]) do |result, param|
        result << case type
                  when :hash
                    "#{param[:name]}: #{param[:name]}"
                  when :response
                    "response[:#{param[:name]}] = #{param[:name]}"
                  else
                    "#{param[:name]} = params[:#{param[:name]}]"
                  end
      end.join("\n")
    end

    def rb_action(action)
      action[:type] == "conditional" ?
        rb_conditional(action) : rb_always(action)
    end

    def rb_conditional(action)
      <<-EOS.strip
if (#{rb_condition(action[:condition])})
#{indent(rb_then(action[:then]), 1)}
  response[:result] = true
else
#{indent(rb_else(action[:else]), 1)}
  response[:result] = false
end
      EOS
    end

    def rb_always(action)
      <<-EOS.strip
#{rb_databases(action[:databases])}
#{rb_interfaces(action[:interfaces])}
EOS
    end

    def rb_condition(condition)
      "#{rb_condition_left(condition[:left])} #{rb_condition_operand(condition[:operand])} #{rb_condition_right(condition[:right])}"
    end

    def rb_condition_hand(hand)
      case hand[:type]
      when "param" then hand[:value][:name]
      when "literal" then "\"#{hand[:value][:value]}\""
      else
        raise "Undefined hand type!"
      end
    end

    alias rb_condition_left rb_condition_hand
    alias rb_condition_right rb_condition_hand

    def rb_condition_operand(operand)
      case operand
      when "eq" then "=="
      when "neq" then "!="
      when "lt" then "<"
      when "gt" then ">"
      else
        raise "Undefined operand!"
      end
    end

    alias rb_then rb_always
    alias rb_else rb_always

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
#{indent(rb_params(database[:params], :hash, 2), 1)}
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
          result << "var #{param[:name]} = #{js_get_element_value(param[:value])}"
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
#{indent(js_params_js(event[:params]), 1)}
  $.ajax({
    type: 'POST',
    url: '/#{event[:id]}',
    params: { #{js_params_json(event[:params])} },
    success: function(_xhr_msg) {
      var _response = JSON.parse(_xhr_msg);
#{indent(js_action(event[:action]), 3)}
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
      EOS
    end

    def js_realtime_event(event)
      <<-EOS
$('\##{event[:target]}').#{js_trigger_function(event[:type])}(function() {
#{indent(js_params_js(event[:params]), 1)}
  var params = { #{js_params_json(event[:params])} };
  var request = { 'func': '#{event[:id]}', 'params': params };
  ws.send(JSON.stringfy(request));
});
      EOS
    end

    def js_onmessage(event)
      <<-EOS
case '#{event[:id]}':
  var _response = _ws_json['msg'];
#{indent(js_action(event[:action]), 1)}
  break;
      EOS
    end

    def js_action(action)
      action[:type] == "conditional" ?
        js_conditional(action) : js_always(action[:interfaces])
    end

    def js_conditional(action)
      <<-EOS
if (_response['result']) {
#{indent(js_then(action[:then][:interfaces]), 1)}
} else {
#{indent(js_then(action[:else][:interfaces]), 1)}
}
      EOS
    end

    def js_always(interfaces)
      interfaces.inject([]) do |result, interface|
        result << js_interface(interface)
      end.join("\n")
    end

    alias js_then js_always
    alias js_else js_always

    def js_interface(interface)
      result = ["var #{interface[:id]} = _response['#{interface[:id]}'];"]

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
        "$('\##{interface[:element]}').val(#{interface[:id]}['#{interface[:params][0][:name]}']);"
      else
        ""
      end
    end
  end
end
