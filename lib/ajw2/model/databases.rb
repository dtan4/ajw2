module Ajw2::Model
  class Databases
    attr_reader :source

    def initialize(source)
      @source = source
    end

    def render_schema
      @source[:database].inject([]) { |schema, table| schema << render_table_schema(table) }
    end

    def render_migration
      @source[:database].inject([]) { |migration, table| migration << render_table_migration(table) }
    end

    private
    def render_table_schema(table)
      schema = ["create_table \"#{table[:tablename]}\", force: true do |t|"]
      schema.concat render_schema_fields(table)
      schema << "end"
      schema.join("\n") + "\n"
    end

    def render_schema_fields(table)
      table[:property].inject([]) do |fields, field|
        fields << render_field(field, false)
      end.concat [
                  "  t.datetime \"created_at\", null: false",
                  "  t.datetime \"updated_at\", null: false"
                 ]
    end

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
      migration = ["create_table :#{table[:tablename]} do |t|"]
      migration.concat render_migration_fields(table)
      migration << "end"
      migration.join("\n") + "\n"
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
