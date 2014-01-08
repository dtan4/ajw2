module Ajw2::Model::EventRenderer
  # Generate Ruby code from Events model
  class JavaScript
    include Ajw2::Util

    # Generate JavaScript code using Ajax
    # @param [Hash] event Events model description
    # @return [String] JavaScript code
    def render_ajax(event)
      raise "event/trigger is not found" unless event[:trigger]
      raise "event/action is not found" unless event[:action]

      trigger = event[:trigger]

      if trigger[:type] == "ready"
        js_body_ajax(event)
      else
        <<-EOS
$('\##{trigger[:target]}').#{trigger_function(trigger[:type])}(function() {
#{indent(js_body_ajax(event), 1)}
});
        EOS
      end
    end

    # Generate JavaScript code using WebSocket
    # @param [Hash] event Events model description
    # @return [String] JavaScript code
    def render_realtime(event)
      raise "event/trigger is not found" unless event[:trigger]
      raise "event/action is not found" unless event[:action]

      trigger = event[:trigger]

      if trigger[:type] == "ready"
        js_body_realtime(event)
      else
        <<-EOS
$('\##{trigger[:target]}').#{trigger_function(trigger[:type])}(function() {
#{indent(js_body_realtime(event), 1)}
});
        EOS
      end
    end

    # Generate JavaScript code which receives message via WebSocket
    # @param [Hash] event Events model description
    # @return [String] JavaScript code
    def render_onmessage(event)
      raise "event/trigger is not found" unless event[:trigger]
      raise "event/action is not found" unless event[:action]

      <<-EOS
case '#{event[:id]}':
#{indent(action_js(event[:action]), 1)}
  break;
      EOS
    end

    private

    # var message = $('#messageTextBox').val();
    # $.ajax({
    #   type: 'POST',
    #   url: '/event01',
    #   data: { 'message': message },
    #   beforeSend: function(_xhr) {
    #     _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
    #   },
    #   success: function(_msg) {
    #     if (_msg['_db_errors'].length == 0) {
    #       var if01 = _msg['if01'];
    #       $('#messageLabel').val(if01);
    #     } else {
    #     }
    #   },
    #   error: function(_xhr, _msg) {
    #     alert('XMLHttpRequest Error: ' + _msg);
    #   }
    # });
    def js_body_ajax(event)
      <<-EOS
#{params_js(event[:trigger][:params])}
$.ajax({
  type: 'POST',
  url: '/#{event[:id]}',
  data: { #{params_json(event[:trigger][:params])} },
  beforeSend: function(_xhr) {
    _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
  },
  success: function(_msg) {
#{indent(action_js(event[:action]), 2)}
  },
  error: function(_xhr, _msg) {
    alert('XMLHttpRequest Error: ' + _msg);
  }
});
       EOS
    end

    # var message = $('#messageTextBox').val();
    # var params = { 'message': message };
    # var request = { 'func': 'event01', 'params': params };
    # ws.send(JSON.stringify(request));
    def js_body_realtime(event)
      <<-EOS
#{params_js(event[:trigger][:params])}
var params = { #{params_json(event[:trigger][:params])} };
var request = { 'func': '#{event[:id]}', 'params': params };
ws.send(JSON.stringify(request));
      EOS
    end

    # value[:type] == "getValue":
    #   $('#messageTextBox').val();
    def get_element_value(value)
      case value[:func]
      when "getValue"
        "$('\##{value[:element]}').val();"
      else ""
      end
    end

    # param[:value][:type] == "element":
    #   var message = $('#messageTextBox').val();
    def params_js(params)
      params.inject([]) do |result, param|
        result << "var #{param[:id]} = #{get_element_value(param[:value])}" if param[:value][:type] == "element"
        result
      end.join("\n")
    end

    def params_json(params)
      params.inject([]) do |result, param|
        result << "'#{param[:id]}': #{param[:id]}" if param[:value][:type] == "element"
        result
      end.join(", ")
    end

    # var id = _msg['id'];
    def set_action_variable(id)
      "var #{id} = _msg['#{id}'];"
    end

    # type == "onClick":
    #   click
    # type == "onChange":
    #   change
    # type == "onFocus":
    #   focus
    # type == "onFocusOut":
    #   blur
    def trigger_function(type)
      case type
      when "onClick" then "click"
      when "onChange" then "change"
      when "onFocus" then "focus"
      when "onFocusOut" then "blur"
      else raise "Undefined trigger function!"
      end
    end

    def action_js(action)
      action[:type] == "conditional" ?
        conditional(action) : always(action)
    end

    # if (_msg['result']) {
    #   if (_msg['_db_errors'].length == 0) {
    #     var if01 = _msg['if01'];
    #     $('#messageLabel').val(if01);
    #   } else {
    #   }
    # } else {
    #   if (_msg['_db_errors'].length == 0) {
    #   } else {
    #   }
    # }
    def conditional(action)
      <<-EOS
if (_msg['result']) {
#{indent(conditional_then(action[:then]), 1)}
} else {
#{indent(conditional_else(action[:else]), 1)}
}
      EOS
    end

    # if (_msg['_db_errors'].length == 0) {
    #   var if01 = _msg['if01'];
    #   $('#messageLabel').val(if01);
    # } else {
    # }
    def always(action)
      <<-EOS
if (_msg['_db_errors'].length == 0) {
#{indent(actions_js(action), 1)}
} else {
}
      EOS
    end

    alias conditional_then always
    alias conditional_else always

    def actions_js(action)
      action[:actions].inject([]) do |result, act|
        result << case act[:type]
                  when "interface"
                    interface_js(act)
                  when "database"
                    database_js(act)
                  when "call"
                    call_js(act)
                  else
                  end
      end.join("\n")
    end

    def call_js(call)
      case call[:call_type]
      when "url"
        call_url(call)
      when "script"
        call_script(call)
      else
        raise Exception
      end
    end

    def call_url(call)
      ""
    end

    def call_script(call)
      <<-EOS
#{set_action_variable(call[:id])}
#{call[:script]}
EOS
    end

    def database_js(database)
      ""
    end

    # var if01 = _msg['if01'];
    # $('#messageLabel').val(if01);
    def set_value(interface)
      <<-EOS
#{set_action_variable(interface[:id])}
$('\##{interface[:element]}').val(#{interface[:id]});
      EOS
    end

    # var if01 = _msg['if01'];
    # $('#messageLabel').text(if01);
    def set_text(interface)
      <<-EOS
#{set_action_variable(interface[:id])}
$('\##{interface[:element]}').text(#{interface[:id]});
      EOS
    end

    # $('#messageLabel').toggle();
    def change_element_visibility(interface, type)
      "$('\##{interface[:element]}')." << type.to_s << "();"
    end

    def interface_js(interface)
      case interface[:func]
      when "setValue"
        set_value(interface)
      when "setText"
        set_text(interface)
      when "show"
        change_element_visibility(interface, :show)
      when "hide"
        change_element_visibility(interface, :hide)
      when "toggle"
        change_element_visibility(interface, :toggle)
      when "appendElements"
        <<-EOS
var #{interface[:id]} = _msg['#{interface[:id]}'];
#{append_elements(interface)}
        EOS
      else
        ""
      end
    end

    def append_elements(interface)
      interface[:params].inject([]) do |result, param|
        result << "$('\##{interface[:element]}').append(#{append_child_element(param, interface[:id])});"
        result
      end.join("\n")
    end

    def append_child_element(element, id)
      result = "$('<#{element[:tag]}>')"
      result << ".val(#{id})" if element[:value]
      result << ".text(#{id})" if element[:text]
      element[:children].each do |elem|
        result << ".append(#{append_child_element(elem, id)})"
      end if element[:children]
      result
    end
  end
end
