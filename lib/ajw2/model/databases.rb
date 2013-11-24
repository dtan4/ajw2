require "erb"

module Ajw2::Model
  class Databases
    attr_reader :source

    def initialize(source)
      @source = source
    end

    def render_migration
      @source[:database].inject([]) { |migration, table| migration << render_table_migration(table) }
    end

    private
    MIGRATION_UP_ERB = <<-EOS
create_table :<%= tablename %> do |t|
<%= fields.join("\n") %>
end
    EOS

    def render_field(field, symbol)
        line = case field[:type]
               when :password
                 "  t.string " + (symbol ? ":crypted_#{field[:name]}" : "\"crypted_#{field[:name]}\"")
               when :role # TODO role validation
                 "  t.string " + (symbol ? ":#{field[:name]}" : "\"#{field[:name]}\"")
               else
                 "  t.#{field[:type]} " + (symbol ? ":#{field[:name]}" : "\"#{field[:name]}\"")
               end
        line << ", null: false" unless field[:null].nil? || field[:null]
        line
    end

    def render_table_migration(table)
      {
       tablename: table[:tablename],
       up: render_up_migration(table),
       down: render_down_migration(table)
      }
    end

    def render_up_migration(table)
      erb = ERB.new(MIGRATION_UP_ERB)
      tablename = table[:tablename]
      fields = render_migration_fields(table)
      erb.result(binding)
    end

    def render_migration_fields(table)
      table[:property].inject([]) do |fields, field|
        fields << render_field(field, true)
      end.concat ["  t.timestamps"]
    end

    def render_down_migration(table)
      "drop_table :#{table[:tablename]}\n"
    end
  end
end
