require "active_support/inflector"

module Ajw2::Model
  class Events
    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Events section must be a Hash" unless source.class == Hash
      @source = source
    end

    def render_rb
      raise Exception unless @source[:events]

      @source[:events].inject([]) { |result, event| result << render_rb_event(event) }
    end

    private

    def render_rb_event(event)
      <<-EOS
post "/#{event[:id]}" do
  content_type :json
  response = {}
#{render_rb_params(event[:params], :ruby, 1)}
#{render_action(event[:action])}
  response.to_json
end
      EOS
    end

    def render_rb_params(params, type, indent)
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

    def render_action(action)
      action[:type] == "conditional" ?
        render_conditional_action(action) : render_always_action(action)
    end

    def render_conditional_action(action)

    end

    def render_always_action(action)
      <<-EOS.chomp
#{render_rb_databases(action[:databases])}
#{render_rb_interfaces(action[:interfaces])}
EOS
    end

    def render_rb_databases(databases)
      databases.inject([]) do |result, database|
        result << render_rb_database(database)
      end.join("\n")
    end

    def render_rb_database(database)
      case database[:func]
      when "create" then render_rb_create(database)
      when "read" then render_rb_read(database)
      when "update" then render_rb_update(database)
      when "delete" then render_rb_delete(database)
      else
        raise Exception
      end
    end

    def render_rb_create(database)
      <<-EOS.chomp
  #{database[:id]} = #{database[:database].singularize.capitalize}.new(
#{render_rb_params(database[:params], :hash, 2)}
  )
  #{database[:id]}.save
      EOS
    end

    def render_rb_read(database)

    end

    def render_rb_update(database)

    end

    def render_rb_delete(database)

    end

    def render_rb_hash(params)

    end

    def render_rb_interfaces(interfaces)
      interfaces.inject([]) do |result, interface|
        result << render_rb_interface(interface)
      end.join("\n")
    end

    def render_rb_interface(interface)
      case interface[:func]
      when "signup"
      when "signin"
      when "setValue"
        render_rb_params(interface[:params], :response, 1)
      end
    end
  end
end
