module Ajw2::Model::Event
  # Generate Ruby code from Events model
  class JavaScript
    include Ajw2::Util

    # Generate JavaScript code using Ajax
    # @param [Hash] event Events model description
    # @return [String] JavaScript code
    def render_ajax(event)
      trigger = event[:trigger]
      action = event[:action]

      if trigger[:type] == "ready"
        js_body_ajax(trigger, action)
      else
        <<-EOS
$('\##{trigger[:target]}').#{trigger_function(trigger[:type])}(function() {
#{indent(js_body_ajax(trigger, action), 1)}
});
        EOS
      end
    end

    # Generate JavaScript code using WebSocket
    # @param [Hash] event Events model description
    # @return [String] JavaScript code
    def render_realtime(event)
      trigger = event[:trigger]
      action = event[:action]

      if trigger[:type] == "ready"
        js_body_realtime(trigger, action)
      else
        <<-EOS
$('\##{trigger[:target]}').#{trigger_function(trigger[:type])}(function() {
#{indent(js_body_realtime(trigger, action), 1)}
});
        EOS
      end
    end

    # Generate JavaScript code which receives message via WebSocket
    # @param [Hash] event Events model description
    # @return [String] JavaScript code
    def render_onmessage(event)
      trigger = event[:trigger]
      action = event[:action]

      <<-EOS
case '#{trigger[:id]}':
#{indent(action_js(action), 1)}
  break;
      EOS
    end

    private

    def js_body_ajax(trigger, action)
      <<-EOS
#{params_js(trigger[:params])}
$.ajax({
  type: 'POST',
  url: '/#{trigger[:id]}',
  data: { #{params_json(trigger[:params])} },
  beforeSend: function(_xhr) {
    _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
  },
  success: function(_msg) {
#{indent(action_js(action), 2)}
  },
  error: function(_xhr, _msg) {
    alert('XMLHttpRequest Error: ' + _msg);
  }
});
       EOS
    end

    def js_body_realtime(trigger, action)
      <<-EOS
#{params_js(trigger[:params])}
var params = { #{params_json(trigger[:params])} };
var request = { 'func': '#{trigger[:id]}', 'params': params };
ws.send(JSON.stringify(request));
      EOS
    end

    def get_element_value(value)
      case value[:func]
      when "getValue"
        "$('\##{value[:element]}').val();"
      else ""
      end
    end

    def params_js(params)
      params.inject([]) do |result, param|
        case param[:value][:type]
        when "element"
          result << "var #{param[:name]} = #{get_element_value(param[:value])}"
        else
          raise "Undefined event value type!"
        end

      end.join("\n")
    end

    def params_json(params)
      params.inject([]) do |result, param|
        result << "'#{param[:name]}': #{param[:name]}"
      end.join(" ")
    end

    def trigger_function(type)
      case type
      when "onClick" then "click"
      else raise "Undefined trigger function!"
      end
    end

    def action_js(action)
      action[:type] == "conditional" ?
        conditional(action) : always(action[:interfaces])
    end

    def conditional(action)
      <<-EOS
if (_msg['result']) {
#{indent(conditional_then(action[:then][:interfaces]), 1)}
} else {
#{indent(conditional_else(action[:else][:interfaces]), 1)}
}
      EOS
    end

    def always(interfaces)
      <<-EOS
if (_msg['_db_errors'].length == 0) {
#{indent(interfaces_js(interfaces), 1)}
} else {
}
      EOS
    end

    alias conditional_then always
    alias conditional_else always

    def interfaces_js(interfaces)
      interfaces.inject([]) do |result, interface|
        result << interface_js(interface)
      end.join("\n")
    end

    def interface_js(interface)
      case interface[:type]
      when "element"
        set_values = element_action(interface)
      else
        raise "Undefined interface action target type!"
      end

      <<-EOS
var #{interface[:id]} = _msg['#{interface[:id]}'];
#{set_values}
      EOS
    end

    def element_action(interface)
      case interface[:func]
      when "setValue"
        raise "Too many parameters!" unless interface[:params].length == 1
        <<-EOS
$('\##{interface[:element]}').val(#{interface[:id]}['#{interface[:params][0][:name]}']);
        EOS
      when "setText"
        raise "Too many parameters!" unless interface[:params].length == 1
        <<-EOS
$('\##{interface[:element]}').text(#{interface[:id]}['#{interface[:params][0][:name]}']);
        EOS
      when "appendElements"
        interface[:params].inject([]) do |result, param|
          result << "$('\##{interface[:element]}').append(#{append_element(param, interface[:id])});"
          result
        end.join("\n")
      else
        ""
      end
    end

    def append_element(element, id)
      result = "$('<#{element[:tag]}>')"
      result << ".val(#{id}['#{element[:value][:name]}'])" if element[:value]
      result << ".text(#{id}['#{element[:text][:name]}'])" if element[:text]
      element[:children].each do |elem|
        result << ".append(#{append_element(elem, id)})"
      end if element[:children]
      result
    end
  end
end
