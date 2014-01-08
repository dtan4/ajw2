require "active_support/inflector"

module Ajw2::Model
  # Generate source code from Database model
  class Database
    include Ajw2::Util

    attr_reader :source

    # Initializer
    # @param [Hash] source entire model description
    def initialize(source)
      raise ArgumentError, "Database section must be a Hash" unless source.class == Hash
      @source = source
    end

    # Generate Ruby code which does database migration
    # @return [Array] collection of generated code
    def render_migration
      raise "/database/databases is not found" unless @source[:databases]

      @source[:databases].inject([]) { |migration, table| migration << render_migration_table(table) }
    end

    # Generate Ruby code which defines ActiveRecord model
    # @return [Array] collection of generated code
    def render_definition
      raise "/database/databases is not found" unless @source[:databases]

      @source[:databases].inject([]) { |definition, table| definition << render_definition_table(table) }
    end

    # Generate YAML which sets up database
    # @return [String] YAML
    def render_config(env, application)
      raise "/database/dbType is not found" unless @source[:dbType]

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

    # Generate gem requirement of database adapter
    # @return [String] gem requirement
    def render_database_gem
      raise "/database/dbType is not found" unless @source[:dbType]

      case @source[:dbType]
      when "mysql"
        'gem "mysql2"'
      when "postgres"
        'gem "pg"'
      else
        'gem "sqlite3"'
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
      !field[:null] ? "validates_presence_of :#{field[:name]}" :  ""
    end
  end
end
