require "active_support/core_ext/hash"
require "json"
require "yaml"

module Ajw2
  class Ajml
    attr_reader :name, :interfaces, :databases, :events

    def initialize
      @name = ""
      @interfaces = {}
      @databases = {}
      @events = {}
    end

    def parse(path)
      ext = File.extname(path)

      case ext
      when /^\.(x|aj)ml$/i
        parse_xml(path)
      when /^\.json$/i
        parse_json(path)
      when /^\.ya?ml$/i
        parse_yaml(path)
      else
        raise Exception
      end
    end

    def parse_xml(path)
      xml = open(path).read
      extract_application_section(Hash.from_xml(xml))
    end

    def parse_json(path)
      json = open(path).read
      extract_application_section(JSON.parse(json))
    end

    def parse_yaml(path)
      yaml = open(path).read
      extract_application_section(YAML.load(yaml))
    end

    def extract_application_section(ajml)
      (ajml["ajml"] && ajml["ajml"]["application"]) ? ajml["ajml"]["application"] : ajml
    end

    def validate(ajml)
      result = true
      msg = []

      unless ajml["name"]
        result = false
        msg << "name is missing"
      end

      unless ajml["interfaces"]
        result = false
        msg << "interfaces section is missing"
      end

      unless ajml["databases"]
        result = false
        msg << "databases section is missing"
      end

      unless ajml["events"]
        result = false
        msg << "events section is missing"
      end

      return result, msg
    end

    def validate_interfaces(interfaces)
      true
    end

    def validate_databases(databases)
      true
    end

    def validate_events(events)
      true
    end
  end
end
