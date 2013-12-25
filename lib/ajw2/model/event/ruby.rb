module Ajw2::Model::Event
  # Generate Ruby code from Events model
  class Ruby
    include Ajw2::Util

    # Generate Ruby code using WebSocket
    # @param [Hash] event Events model description
    # @return [String] Ruby code
    def render_realtime(event)
      trigger = event[:trigger]
      <<-EOS
when "#{trigger[:id]}"
  response[:_db_errors] = []
  response[:_event] = "#{trigger[:id]}"
#{indent(params_rb(trigger[:params]), 1)}
#{indent(action_rb(event[:action]), 1)}
  EventMachine.next_tick do
    settings.sockets.each { |s| s.send(response.to_json) }
  end
      EOS
    end

    # Generate Ruby code using Ajax
    # @param [Hash] event Events model description
    # @return [String] Ruby code
    def render_ajax(event)
      trigger = event[:trigger]
      <<-EOS
post "/#{trigger[:id]}" do
  content_type :json
  response = { _db_errors: [] }
#{indent(params_rb(trigger[:params]), 1)}
#{indent(action_rb(event[:action]), 1)}
  response.to_json
end
      EOS
    end

    private

    def params_rb(params, hash = false)
      params.inject([]) do |result, param|
        result <<
          (hash ? "#{param[:name]}: #{param[:name]}" : "#{param[:name]} = params[:#{param[:name]}]")
        result
      end.join("\n")
    end

    def action_rb(action)
      action[:type] == "conditional" ?
        conditional(action) : always(action)
    end

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
      <<-EOS.strip
#{databases_rb(action[:databases])}
if response[:_db_errors].length == 0
#{indent(interfaces_rb(action[:interfaces]), 1)}
end
EOS
    end

    def condition(condition)
      "#{condition_left(condition[:left])} #{condition_operand(condition[:operand])} #{condition_right(condition[:right])}"
    end

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

    alias conditional_then always
    alias conditional_else always

    def databases_rb(databases)
      databases.inject([]) do |result, database|
        result << database_rb(database)
      end.join("\n")
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

    def field_param(array)
      array.inject([]) do |result, pair|
        result << "#{pair[:field]}: #{pair[:param]}"
        result
      end.join(", ")
    end

    def create(database)
      <<-EOS.chomp
#{database[:id]} = #{database[:database].singularize.capitalize}.new(
#{indent(field_param(database[:fields]), 1)}
)
response[:_db_errors] << { #{database[:id]}: #{database[:id]}.errors.full_messages } unless #{database[:id]}.save
      EOS
    end

    def read(database)

    end

    def update(database)

    end

    def delete(database)
      <<-EOS.chomp
#{database[:id]} = #{database[:database].singularize.capitalize}.where(
#{indent(field_param(database[:where]), 1)}
)
#{database[:id]}.destroy
      EOS
    end

    def hash(params)

    end

    def interfaces_rb(interfaces)
      interfaces.inject([]) do |result, interface|
        result << <<-EOS
response[:#{interface[:id]}] = {}
#{interface_rb(interface)}
                  EOS
      end.join("\n")
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

    def interface_set_params(interface)
      interface[:params].inject([]) do |result, param|
        result << "response[:#{interface[:id]}][:#{param[:name]}] = #{param[:name]}"
      end.join("\n")
    end

    def interface_set_params_append(elements, id)
      elements.inject([]) do |result, el|
        [:value, :text].each do |attr|
          result <<
            "response[:#{id}][:#{el[attr][:name]}] = #{el[attr][:name]}" if el[attr]
        end
        result << interface_set_params_append(el[:children], id) if el[:children]
        result
      end.join("\n")
    end
  end
end
