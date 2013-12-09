require "active_support/inflector"

module Ajw2::Model
  class Databases
    include Ajw2

    attr_reader :source

    def initialize(source)
      raise ArgumentError, "Databases section must be a Hash" unless source.class == Hash
      @source = source
    end

    def render_migration
      raise "/databases/database is not found" unless @source[:database]

      @source[:database].inject([]) { |migration, table| migration << render_migration_table(table) }
    end

    def render_definition
      raise "/databases/database is not found" unless @source[:database]

      @source[:database].inject([]) { |definition, table| definition << render_definition_table(table) }
    end

    def render_config(env, application)
      raise "/databases/dbType is not found" unless @source[:dbType]

      case @source[:dbType]
      when "mysql"
        <<-EOS
adapter: mysql2
encoding: utf8
reconnect: true
database: #{application.name}_#{env}
pool: 5
username: root
password:
host: localhost
sock: /tmp/mysql.sock
        EOS
      when "postgres"
        <<-EOS
adapter: postgresql
database: #{application.name}_#{env}
username: root
password:
host: localhost
port: 5432
        EOS
      else
        <<-EOS
adapter: sqlite3
database: db/#{env}.sqlite3
pool: 5
timeout: 5000
        EOS
      end
    end

    private

    def add_encrypted_prefix(name)
      "encrypted_#{name}"
    end

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
#{indent(render_migration_fields(table[:property]), 1)}
end
         EOS
    end

    def render_migration_fields(fields)
      fields.inject([]) do |r_fields, field|
        r_fields << render_migration_field(field)
      end.concat(["t.timestamps"]).join("\n")
    end

    def render_migration_field(field)
      case field[:type]
      when "password"
        "t.string :#{add_encrypted_prefix(field[:name])}"
      when "role" # TODO role validation
        "t.string :#{field[:name]}"
      else
        "t.#{field[:type]} :#{field[:name]}"
      end
    end

    def render_down_migration(table)
      "drop_table :#{table[:tablename]}\n"
    end

    def render_definition_table(table)
      <<-EOS
class #{table[:tablename].singularize.capitalize} < ActiveRecord::Base
#{indent(render_definition_fields(table[:property]), 1)}
end
      EOS
    end

    def render_definition_fields(fields)
      fields.inject([]) do |r_fields, field|
        r_fields << render_definition_field(field)
      end.delete_if { |field| field == "" }.join("\n")
    end

    def render_definition_field(field)
      field[:name] = add_encrypted_prefix(field[:name]) if field[:type] == "password"
      if !field[:null]
        "validates_presence_of :#{field[:name]}"
      else
        ""
      end
    end

    def render_config_env(env, application)

    end
  end
end
