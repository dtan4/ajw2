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

      @source[:events].inject([]) { |result, event| result << rb_realtime_event(event) } unless @source[:realtime]
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
  end
end
