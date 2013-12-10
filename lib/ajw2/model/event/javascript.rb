module Ajw2::Model::Event
  class JavaScript
    include Ajw2::Util

    def ajax_event(event)
      <<-EOS
$('\##{event[:target]}').#{trigger_function(event[:type])}(function() {
#{indent(params_js(event[:params]), 1)}
  $.ajax({
    type: 'POST',
    url: '/#{event[:id]}',
    params: { #{params_json(event[:params])} },
    success: function(_xhr_msg) {
      var _response = JSON.parse(_xhr_msg);
#{indent(action_js(event[:action]), 3)}
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
      EOS
    end

    def realtime_event(event)
      <<-EOS
$('\##{event[:target]}').#{trigger_function(event[:type])}(function() {
#{indent(params_js(event[:params]), 1)}
  var params = { #{params_json(event[:params])} };
  var request = { 'func': '#{event[:id]}', 'params': params };
  ws.send(JSON.stringfy(request));
});
      EOS
    end

    def onmessage(event)
      <<-EOS
case '#{event[:id]}':
  var _response = _ws_json['msg'];
#{indent(action_js(event[:action]), 1)}
  break;
      EOS
    end

    private

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
if (_response['result']) {
#{indent(conditional_then(action[:then][:interfaces]), 1)}
} else {
#{indent(conditional_else(action[:else][:interfaces]), 1)}
}
      EOS
    end

    def always(interfaces)
      interfaces.inject([]) do |result, interface|
        result << interface(interface)
      end.join("\n")
    end

    alias conditional_then always
    alias conditional_else always

    def interface(interface)
      case interface[:type]
      when "element"
        set_values = element_action(interface)
      else
        raise "Undefined interface action target type!"
      end

      <<-EOS
var #{interface[:id]} = _response['#{interface[:id]}'];
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
      element[:children].each do |elem|
        result << ".append(#{append_element(elem, id)})"
      end if element[:children]
      result
    end
  end
end
