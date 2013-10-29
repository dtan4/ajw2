require "erb"

module Ajw2::Template
  class Element
    INPUT_TYPE = %w{hidden text search url telephone email password datetime date month week time datetime-local number range color checkbox radio file submit image reset button}

    def input(options)
      raise Exception unless options[:type] && INPUT_TYPE.include?(options[:type])

      options = escape_options(options)

      erb = '<input type="<%= options[:type] %>"'
      erb << ' id="<%= options[:id] %>"' if options[:id]
      erb << ' name="<%= options[:name] %>"' if options[:name]
      erb << ' value="<%= options[:value] %>"' if options[:value]
      erb << '>'

      ERB.new(erb).result(binding)
    end

    def escape_options(options)
      options.each_pair { |key, val| options[key] = CGI.escapeHTML(val) }
    end
  end
end
