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

      if ajml["name"]
        nm_result, nm_msg = validate_name(ajml["name"])
        result &= nm_result
        msg.concat(nm_msg) if nm_msg
      else
        result = false
        msg << "name is missing"
      end

      if ajml["interfaces"]
        if_result, if_msg = validate_interfaces(ajml["interfaces"])
        result &= if_result
        msg.concat(if_msg) if if_msg
      else
        result = false
        msg << "interfaces section is missing"
      end

      if ajml["databases"]
        db_result, db_msg = validate_databases(ajml["databases"])
        result &= db_result
        msg.concat(db_msg) if db_msg
      else
        result = false
        msg << "databases section is missing"
      end

      if ajml["events"]
        ev_result, ev_msg = validate_events(ajml["events"])
        result &= ev_result
        msg.concat(ev_msg) if ev_msg
      else
        result = false
        msg << "events section is missing"
      end

      return result, msg
    end

    def validate_name(name)
      result = true
      msg = []

      return result, msg
    end

    def validate_interfaces(interfaces)
      result = true
      msg = []

      return result, msg
    end

    def validate_databases(databases)
      result = true
      msg = []

      return result, msg
    end

    def validate_events(events)
      result = true
      msg = []

      return result, msg
    end
  end
end
