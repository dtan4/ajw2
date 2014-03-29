require "active_support/inflector"

module Ajw2::Model
  # Generate source code from Database model
  class Database
    include Ajw2::Util

    attr_reader :source

    # Initializer
    # @param [Hash] source entire model description
    def initialize(source)
      fail ArgumentError, "Database section must be a Hash" unless source.class == Hash
      @source = source
    end

    # Generate Ruby code which does database migration
    # @return [Array] collection of generated code
    def render_migration
      render_rb(:migration)
    end

    # Generate Ruby code which defines ActiveRecord model
    # @return [Array] collection of generated code
    def render_definition
      render_rb(:definition)
    end

    # Generate YAML which sets up database
    # @return [String] YAML
    def render_config(env, application)
      fail "/database/dbType is not found" unless @source[:dbType]

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
      fail "/database/dbType is not found" unless @source[:dbType]

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

    def render_rb(type)
      fail "/database/tables is not found" unless @source[:tables]

      @source[:tables].inject([]) { |definition, table| definition << send("render_#{type}_table", table) }
    end

    def add_encrypted_prefix(name)
      "encrypted_#{name}"
    end

    def render_migration_table(table)
      {
       name: table[:name],
       up: render_up_migration(table),
       down: render_down_migration(table)
      }
    end

    def render_up_migration(table)
      <<-EOS
create_table :#{table[:name]} do |t|
#{indent(render_migration_fields(table[:fields]), 1)}
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
      "drop_table :#{table[:name]}\n"
    end

    def render_definition_table(table)
      <<-EOS
class #{table[:name].singularize.capitalize} < ActiveRecord::Base
#{indent(render_definition_fields(table[:fields]), 1)}
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
      !field[:nullable] ? "validates_presence_of :#{field[:name]}" :  ""
    end
  end
end
