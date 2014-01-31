require "json"
require "yaml"
require "ajw2/util"

module Ajw2
  # Model source
  class Source
    include Ajw2::Util

    attr_reader :application, :interface, :database, :event

    # Parse given file
    # @param [String] path path to model description (JSON or YAML)
    # @return [Hash] Hash of model description created from given file
    def parse_file(path)
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
      create_models(JSON.parse(json, symbolize_names: true))
    end

    def parse_yaml(path)
      yaml = open(path).read
      create_models(symbolize_keys(YAML.load(yaml)))
    end

    def create_models(source)
      @application = Ajw2::Model::Application.new(source[:application])
      @interface = Ajw2::Model::Interface.new(source[:interface])
      @database = Ajw2::Model::Database.new(source[:database])
      @event = Ajw2::Model::Event.new(source[:event])
    end
  end
end
