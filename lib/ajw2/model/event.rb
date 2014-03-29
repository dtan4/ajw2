module Ajw2::Model
  # Generate source code from Events model
  class Event
    attr_reader :source

    # Initializer
    # @param [Hash] source entire model description
    # @param [Ajw2::Model::Event::JavaScript] js JavaScript code generator
    # @param [Ajw2::Model::Event::Ruby] rb Ruby code generator
    def initialize(source, js = nil, rb = nil)
      raise ArgumentError, "Event section must be a Hash" unless source.class == Hash
      @source = source
      @js = js || Ajw2::Model::Event::JavaScript.new
      @rb = rb || Ajw2::Model::Event::Ruby.new
    end

    # Generate Ruby code using Ajax
    # @return [Array] collection of generated code
    def render_rb_ajax
      render_code(@rb, :ajax)
    end

    # Generate Ruby code using WebSocket
    # @return [Array] collection of generated code
    def render_rb_realtime
      render_code(@rb, :realtime)
    end

    # Generate JavaScript code using Ajax
    # @return [Array] collection of generated code
    def render_js_ajax
      render_code(@js, :ajax)
    end

    # Generate JavaScript code using WebSocket
    # @return [Array] collection of generated code
    def render_js_realtime
      render_code(@js, :realtime)
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

    def render_code(renderer, event_type)
      raise "/events/events is not found" unless @source[:events]

      @source[:events].inject([]) do |result, event|
        result << renderer.send("render_#{event_type}", event) if event[:type] == event_type.to_s
        result
      end
    end

    class JavaScript
      include Ajw2::Util

      # Generate JavaScript code using Ajax
      # @param [Hash] event Events model description
      # @return [String] JavaScript code
      def render_ajax(event)
        render_event(event, :ajax)
      end

      # Generate JavaScript code using WebSocket
      # @param [Hash] event Events model description
      # @return [String] JavaScript code
      def render_realtime(event)
        render_event(event, :realtime)
      end

      # Generate JavaScript code which receives message via WebSocket
      # @param [Hash] event Events model description
      # @return [String] JavaScript code
      def render_onmessage(event)
        raise "event/trigger is not found" unless event[:trigger]
        raise "event/action is not found" unless event[:action]

      <<-EOS
case '#{event[:id]}':
  if (Object.keys(_msg['_db_errors']).length == 0) {
#{indent(action_js(event[:action]), 2)}
  } else {
  }
  break;
      EOS
      end

      private

      def render_event(event, type)
        raise "event/trigger is not found" unless event[:trigger]
        raise "event/action is not found" unless event[:action]

        trigger = event[:trigger]

        if trigger[:type] == "ready"
          send("js_body_#{type}", event)
        else
        <<-EOS
$('\##{trigger[:target]}').#{trigger_function(trigger[:type])}(function() {
#{indent(send("js_body_#{type}", event), 1)}
});
        EOS
        end
      end

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
    if (Object.keys(_msg['_db_errors']).length == 0) {
#{indent(action_js(event[:action]), 3)}
    } else {
    }
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

      # if (Object.keys(_msg['_db_errors']).length == 0) {
      #   var if01 = _msg['if01'];
      #   $('#messageLabel').val(if01);
      # } else {
      # }
      def action_js(action)
        action[:actions].inject([]) do |result, act|
          result << send("#{act[:type]}_js", act)
          result
        end.join("\n")
      end

      def interface_js(interface)
        case interface[:func]
        when "setValue"
          set_element_attribute(interface, :val)
        when "setText"
          set_element_attribute(interface, :text)
        when "show", "hide", "toggle"
          change_element_visibility(interface)
        when "appendElements"
        <<-EOS
var #{interface[:id]} = _msg['#{interface[:id]}'];
#{append_elements(interface)}
        EOS
        else
          ""
        end
      end

      def set_element_attribute(interface, type)
      <<-EOS
#{set_action_variable(interface[:id])}
$('\##{interface[:element]}').#{type}(#{interface[:id]});
      EOS
      end

      # var id = _msg['id'];
      def set_action_variable(id)
        "var #{id} = _msg['#{id}'];"
      end

      # $('#messageLabel').toggle();
      def change_element_visibility(interface)
        "$('\##{interface[:element]}')." << interface[:func] << "();"
      end

      def append_elements(interface)
        interface[:params].inject([]) do |result, param|
          result << "$('\##{interface[:element]}').append(#{append_child_element(param, interface[:id])});"
          result
        end.join("\n")
      end

      def append_child_element(element, id)
        result = "$('<#{element[:tag]}>')"
        result << ".val(#{id}['#{element[:value][:id]}'])" if element[:value]
        result << ".text(#{id}['#{element[:text][:id]}'])" if element[:text]
        element[:children].each do |elem|
          result << ".append(#{append_child_element(elem, id)})"
        end if element[:children]
        result
      end

      def database_js(database)
        ""
      end

      def api_js(call)
        ""
      end

      def script_js(call)
      <<-EOS
#{set_action_variable(call[:id])}
#{call[:script]}
EOS
      end
    end

    class Ruby
      include Ajw2::Util

      # Generate Ruby code using Ajax
      # @param [Hash] event Events model description
      # @return [String] Ruby code
      def render_ajax(event)
        raise "event/trigger is not found" unless event[:trigger]
        raise "event/action is not found" unless event[:action]

      <<-EOS
post "/#{event[:id]}" do
  content_type :json
  response = { _db_errors: {} }
#{indent(params_rb(event[:trigger][:params]), 1)}
#{indent(action_rb(event[:action]), 1)}
  response.to_json
end
      EOS
      end

      # Generate Ruby code using WebSocket
      # @param [Hash] event Events model description
      # @return [String] Ruby code
      def render_realtime(event)
        raise "event/trigger is not found" unless event[:trigger]
        raise "event/action is not found" unless event[:action]

      <<-EOS
when "#{event[:id]}"
  response[:_db_errors] = {}
  response[:_event] = "#{event[:id]}"
#{indent(params_rb(event[:trigger][:params]), 1)}
#{indent(action_rb(event[:action]), 1)}
  EventMachine.next_tick do
    settings.sockets.each { |s| s.send(response.to_json) }
  end
      EOS
      end

      private

      # id01 = param01
      # id02 = "literal02"
      def params_rb(params)
        params.inject([]) do |result, param|
          value = send("#{param[:value][:type]}_value", param)
          result << "#{param[:id]} = #{value}"
          result
        end.join("\n")
      end

      def element_value(param)
        send("element_#{param[:type]}_value", param[:id])
      end

      def element_integer_value(id)
        "params[:#{id}].to_i"
      end

      def element_decimal_value(id)
        "params[:#{id}].to_f"
      end

      def element_datetime_value(id)
        "Time.parse(params[:#{id}])"
      end

      def element_string_value(id)
        "params[:#{id}]"
      end

      # param[:type] == "integer" || "decimal" || "boolean":
      #   42
      # param[:type] == "string":
      #   "42"
      def literal_value(param)
        case param[:type]
        when "integer", "decimal", "boolean"
          param[:value][:value]
        else
          "\"#{param[:value][:value]}\""
        end
      end

      def action_rb(action)
        action[:actions].inject([]) do |result, act|
          result << send("#{act[:type]}_rb", act)
          result
        end.join("\n")
      end

      def interface_rb(interface)
        case interface[:func]
        when "signup"
          raise "Not implemented yet."
        when "signin"
          raise "Not implemented yet."
        when "setValue", "setText"
          "response[:#{interface[:id]}] = #{set_value(interface[:value])}"
        when "appendElements"
        <<-EOS
response[:#{interface[:id]}] = {}
#{interface_set_params_append(interface[:params], interface[:id])}
        EOS
        end
      end

      def interface_set_params_append(elements, id)
        elements.inject([]) do |result, el|
          [:value, :text].each do |attr|
            result <<
              "response[:#{id}][:#{el[attr][:id]}] = #{el[attr][:id]}" if el[attr]
          end

          result << interface_set_params_append(el[:children], id) if el[:children]
          result
        end.join("\n")
      end

      # /json[0]/path -> [:json][0][:path]
      def parse_jsonpath(jsonpath)
        jsonpath.split("/")[1..-1].inject("") do |result, key|
          if /^(?<k>[a-zA-Z]+)\[(?<i>\d+)\]$/ =~ key
            result << "[:#{k}][#{i}]"
          else
            result << "[:#{key}]"
          end

          result
        end
      end

      # value[:type] == "database"
      #   id.field
      # value[:type] == "api"
      #   id[:json][:path][0]
      def set_value(value)
        send("set_#{value[:type]}_value", value)
      end

      def set_database_value(value)
        "#{value[:id]}.#{value[:field]}"
      end

      def set_api_value(value)
        "#{value[:id]}#{parse_jsonpath(value[:jsonpath])}"
      end

      def set_param_value(value)
        value[:id]
      end

      # field01: value01, field02: value02
      def field_param(array)
        array.inject([]) do |result, field|
          result << "#{field[:field]}: #{set_value(field[:value])}"
          result
        end.join(", ")
      end

      def database_rb(database)
        send(database[:func].to_s, database)
      end

      # db01 = Message.new(
      #   message: message
      # )
      # response[:_db_errors][:db01] = db01.errors.full_messages unless db01.save
      def create(database)
      <<-EOS.chomp
#{database[:id]} = #{database[:database].singularize.capitalize}.new(
#{indent(field_param(database[:fields]), 1)}
)
response[:_db_errors][:#{database[:id]}] = #{database[:id]}.errors.full_messages unless #{database[:id]}.save
      EOS
      end

      # db01 = Message.where(
      #   message: message
      # )
      def read(database)
      <<-EOS.chomp
#{database[:id]} = #{database[:database].singularize.capitalize}.where(
#{indent(field_param(database[:where]), 1)}
)
      EOS
      end

      # db01 = Message.where(
      #   message: message
      # )
      # db01.message = newMessage
      # response[:_db_errors][:db01] = db01.errors.full_messages unless db01.save
      def update(database)
        update_record = database[:fields].inject([]) do |result, field|
          result << "#{database[:id]}.#{field[:field]} = #{set_value(field[:value])}"
          result
        end.join("\n")

      <<-EOS.chomp
#{read(database)}
#{update_record}
response[:_db_errors][:#{database[:id]}] = #{database[:id]}.errors.full_messages unless #{database[:id]}.save
      EOS
      end

      # db01 = Message.where(
      #   message: message
      # )
      # db01.destroy
      def delete(database)
      <<-EOS.chomp
#{read(database)}
#{database[:id]}.destroy
      EOS
      end

      # call01 = http_get(
      #   "http://maps.googleapis.com/maps/api/geocode/json",
      #   address: address, sensor: sensor
      # )
      def api_rb(call)
      <<-EOS
#{call[:id]} = http_#{call[:method]}(
  "#{call[:endpoint]}",
  #{field_param(call[:params])}
)
EOS
      end

      def script_rb(call)
        call[:params].inject(["response[:#{call[:id]}] = {}"]) do |result, param|
          result << "response[:#{call[:id]}][:#{param[:field]}] = #{set_value(param[:value])}"
          result
        end.join("\n")
      end
    end
  end
end
