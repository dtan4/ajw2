module Ajw2::Model::EventRenderer
  # Generate Ruby code from Events model
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
        value = self.send("#{param[:value][:type]}_value", param)
        result << "#{param[:id]} = #{value}"
        result
      end.join("\n")
    end

    def element_value(param)
      self.send("element_#{param[:type]}_value", param[:id])
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
        result << self.send("#{act[:type]}_rb", act)
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
      self.send("set_#{value[:type]}_value", value)
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
      self.send(database[:func].to_s, database)
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
