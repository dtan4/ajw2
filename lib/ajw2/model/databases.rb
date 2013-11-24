require "active_support/inflector"

module Ajw2::Model
  class Databases
    attr_reader :source

    def initialize(source)
      @source = source
    end

    def render_migration
      @source[:database].inject([]) { |migration, table| migration << render_migration_table(table) }
    end

    def render_definition
      @source[:database].inject([]) { |definition, table| definition << render_definition_table(table) }
    end

    private
    def render_migration_table(table)
      {
       tablename: table[:tablename],
       up: render_up_migration(table),
       down: render_down_migration(table)
      }
    end

    def render_up_migration(table)
      <<-EOS
create_table :#{table[:tablename]} do |t|
#{render_migration_fields(table[:property]).join("\n")}
end
         EOS
    end

    def render_migration_fields(fields)
      fields.inject([]) do |r_fields, field|
        r_fields << render_migration_field(field)
      end.concat ["  t.timestamps"]
    end

    def render_migration_field(field)
      case field[:type]
      when :password
        "  t.string :crypted_#{field[:name]}"
      when :role # TODO role validation
        "  t.string :#{field[:name]}"
      else
        "  t.#{field[:type]} :#{field[:name]}"
      end
    end

    def render_down_migration(table)
      "drop_table :#{table[:tablename]}\n"
    end

    def render_definition_table(table)
      <<-EOS
class #{table[:tablename].singularize.capitalize} < ActiveRecord::Base
#{render_definition_fields(table[:property]).join("\n")}
end
      EOS
    end

    def render_definition_fields(fields)
      fields.inject([]) do |r_fields, field|
        r_fields << render_definition_field(field)
      end.delete_if { |field| field == "" }
    end

    def render_definition_field(field)
      field[:name] = "crypted_#{field[:name]}" if field[:type] == :password

      if !field[:null].nil? && !field[:null]
        "  validates_presence_of :#{field[:name]}"
      else
        ""
      end
    end
  end
end
