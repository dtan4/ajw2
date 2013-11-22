module Ajw2::Model
  class Databases
    attr_reader :source

    def initialize(source)
      @source = source
    end

    def render_schema
      @source[:database].inject([]) { |schema, table| schema << render_table_schema(table) }
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
        fields << render_schema_field(field)
      end.concat [
                  "  t.datetime \"created_at\", null: false",
                  "  t.datetime \"updated_at\", null: false"
                 ]
    end

    def render_schema_field(field)
        line = case field[:type]
               when :password
                 "  t.string \"crypted_#{field[:name]}\""
               when :role # TODO role validation
                 "  t.string \"#{field[:name]}\""
               else
                 "  t.#{field[:type]} \"#{field[:name]}\""
               end
        line << ", null: false" unless field[:null].nil? || field[:null]
        line
    end
  end
end
