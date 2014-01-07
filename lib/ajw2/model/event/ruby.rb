module Ajw2::Model::Event
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

    def element_value(param)
      case param[:type]
      when "integer"
        "params[:#{param[:id]}].to_i"
      when "decimal"
        "params[:#{param[:id]}].to_f"
      when "datetime"
        "Time.parse(params[:#{param[:id]}])"
      else
        "params[:#{param[:id]}]"
      end
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

    # id01 = param01
    # id02 = "literal02"
    def params_rb(params)
      params.inject([]) do |result, param|
        result << case param[:value][:type]
                  when "element"
                    "#{param[:id]} = #{element_value(param)}"
                  else
                    "#{param[:id]} = #{literal_value(param)}"
                  end
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
    # value[:type] == "call"
    #   id[:json][:path][0]
    def set_value(value)
      case value[:type]
      when "database"
        "#{value[:id]}.#{value[:field]}"
      when "call"
        "#{value[:id]}#{parse_jsonpath(value[:jsonpath])}"
      else
        value[:id]
      end
    end

    # field01: value01, field02: value02
    def field_param(array)
      array.inject([]) do |result, field|
        result << "#{field[:field]}: #{set_value(field[:value])}"
        result
      end.join(", ")
    end

    def action_rb(action)
      action[:type] == "conditional" ?
        conditional(action) : always(action)
    end

    # if (message == "hoge")
    #   db01 = Message.new(
    #     message: message
    #   )
    #   response[:_db_errors][:db01] = db01.errors.full_messages unless db01.save
    #   response[:if01] = message
    #   response[:result] = true
    # else
    #   response[:result] = false
    # end
    def conditional(action)
      <<-EOS.strip
if (#{condition(action[:condition])})
#{indent(conditional_then(action[:then]), 1)}
  response[:result] = true
else
#{indent(conditional_else(action[:else]), 1)}
  response[:result] = false
end
      EOS
    end

    def always(action)
      action[:actions].inject([]) do |result, act|
        result << case act[:type]
                  when "interface"
                    interface_rb(act)
                  when "database"
                    database_rb(act)
                  when "call"
                    call_rb(act)
                  else
                  end
        result
      end.join("\n")
    end

    alias conditional_then always
    alias conditional_else always

    # message == "hoge"
    def condition(condition)
      "#{condition_left(condition[:left])} #{condition_operand(condition[:operand])} #{condition_right(condition[:right])}"
    end

    # hand[:type] == "param":
    #   42
    # hand[:type] == "literal":
    #   "42"
    def condition_hand(hand)
      case hand[:type]
      when "param" then hand[:value][:name]
      when "literal" then "\"#{hand[:value][:value]}\""
      else
        raise "Undefined hand type!"
      end
    end

    alias condition_left condition_hand
    alias condition_right condition_hand

    def condition_operand(operand)
      case operand
      when "eq" then "=="
      when "neq" then "!="
      when "lt" then "<"
      when "gt" then ">"
      else
        raise "Undefined operand!"
      end
    end

    def call_rb(call)
      case call[:call_type]
      when "url"
        call_url(call)
      when "function"
        call_function(call)
      else
        raise Exception
      end
    end

    # call01 = http_get(
    #   "http://maps.googleapis.com/maps/api/geocode/json",
    #   address: address, sensor: sensor
    # )
    def call_url(call)
      <<-EOS
#{call[:id]} = http_#{call[:method]}(
  "#{call[:endpoint]}",
  #{field_param(call[:params])}
)
EOS
    end

    def call_function(call)
      # TODO: Not Implemented
    end

    def database_rb(database)
      case database[:func]
      when "create" then create(database)
      when "read" then read(database)
      when "update" then update(database)
      when "delete" then delete(database)
      else
        raise Exception
      end
    end

    def update_record(record, array)
      array.inject([]) do |result, field|
        result << "#{record}.#{field[:field]} = #{set_value(field[:value])}"
        result
      end.join("\n")
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
      <<-EOS.chomp
#{read(database)}
#{update_record(database[:id], database[:fields])}
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

    # response[:if01] = message
    def interface_set_params(interface)
      "response[:#{interface[:id]}] = #{set_value(interface[:value])}"
    end

    def interface_rb(interface)
      case interface[:func]
      when "signup"
      when "signin"
      when "setValue", "setText"
        interface_set_params(interface)
      when "appendElements"
        interface_set_params_append(interface[:params], interface[:id])
      end
    end

    def interface_set_params_append(elements, id)
      elements.inject([]) do |result, el|
        [:value, :text].each do |attr|
          result <<
            "response[:#{id}] = #{el[attr][:id]}" if el[attr]
        end
        result << interface_set_params_append(el[:children], id) if el[:children]
        result
      end.join("\n")
    end
  end
end
