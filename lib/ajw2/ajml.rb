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
        ajml = parse_xml(path)
      when /^\.json$/i
        ajml = parse_json(path)
      when /^\.ya?ml$/i
        ajml = parse_yaml(path)
      else
        raise Exception
      end

      if validate(ajml)
        @name = ajml["name"]
        @interfaces = ajml["interfaces"]
        @databases = ajml["databases"]
        @events = ajml["events"]
      else
        raise Exception
      end
    end

    private
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
        unless ajml[el]
          result = false
          msg << "#{el} is missing"
        end
      end

      return result, msg
    end
  end
end
