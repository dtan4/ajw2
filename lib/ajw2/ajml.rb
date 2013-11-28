require "active_support/core_ext/hash"
require "json"
require "yaml"

module Ajw2
  class Ajml
    attr_reader :application, :interfaces, :databases, :events

    def parse(path)
      case File.extname(path)
      when /^\.(x|aj)ml$/i then parse_xml(path)
      when /^\.json$/i then parse_json(path)
      when /^\.ya?ml$/i then parse_yaml(path)
      else
        raise Exception
      end
    end

    private

    def symbolize_keys(argument)
      if argument.class == Hash
        argument.inject({}) do |result, (key, value)|
          result[key.to_sym] = symbolize_keys(value)
          result
        end
      elsif argument.class == Array
        argument.map { |arg| symbolize_keys(arg) }
      else
        argument
      end
    end

    def parse_xml(path)
      xml = open(path).read
      create_models(symbolize_keys(Hash.from_xml(xml)))
    end

    def parse_json(path)
      json = open(path).read
      create_models(symbolize_keys(JSON.parse(json)))
    end

    def parse_yaml(path)
      yaml = open(path).read
      create_models(symbolize_keys(YAML.load(yaml)))
    end

    def create_models(ajml)
      @application = Ajw2::Model::Application.new(ajml[:name])
      @interfaces = Ajw2::Model::Interfaces.new(ajml[:interfaces])
      @databases = Ajw2::Model::Databases.new(ajml[:databases])
      @events = Ajw2::Model::Events.new(ajml[:events])
    end
  end
end
