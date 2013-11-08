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
      # TODO: refactor
      ext = File.extname(path)

      case ext
      when /^\.(x|aj)ml$/i
        app = parse_xml(path)
      when /^\.json$/i
        app = parse_json(path)
      when /^\.ya?ml$/i
        app = parse_yaml(path)
      else
        raise Exception
      end

      @name = app["name"]
      @interfaces = app["interfaces"]
      @databases = app["databases"]
      @events = app["events"]
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

      %w{name interfaces databases events}.each do |el|
        sub_result, sub_msg = self.send(:"validate_#{el}", ajml[el])
        result &= sub_result
        msg.concat(sub_msg) if sub_msg
      end

      return result, msg
    end

    def validate_name(name)
      unless name
        return false, ["name is missing"]
      end

      result = true
      msg = []

      return result, msg
    end

    def validate_interfaces(interfaces)
      unless interfaces
        return false, ["interfaces is missing"]
      end

      result = true
      msg = []

      return result, msg
    end

    def validate_databases(databases)
      unless interfaces
        return false, ["databases is missing"]
      end

      result = true
      msg = []

      return result, msg
    end

    def validate_events(events)
      unless interfaces
        return false, ["events is missing"]
      end

      result = true
      msg = []

      return result, msg
    end
  end
end
