require "active_support/core_ext/hash"
require "json"
require "yaml"
require "ajw2/util"

module Ajw2
  # Model description
  class Description
    include Ajw2::Util

    attr_reader :application, :interfaces, :databases, :events

    # Parse given file
    # @param [String] path path to model description (JSON or YAML)
    # @return [Hash] Hash of model description created from given file
    def parse(path)
      case File.extname(path)
      when /^\.json$/i then parse_json(path)
      when /^\.ya?ml$/i then parse_yaml(path)
      else
        raise Exception
      end
    end

    private

    def parse_json(path)
      json = open(path).read
      create_models(symbolize_keys(JSON.parse(json)))
    end

    def parse_yaml(path)
      yaml = open(path).read
      create_models(symbolize_keys(YAML.load(yaml)))
    end

    def create_models(description)
      @application = Ajw2::Model::Application.new(description[:application])
      @interfaces = Ajw2::Model::Interfaces.new(description[:interfaces])
      @databases = Ajw2::Model::Databases.new(description[:databases])
      @events = Ajw2::Model::Events.new(description[:events])
    end
  end
end
