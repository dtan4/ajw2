require "pathname"

module Ajw2
  class Cli
    def self.execute(args)
      source, out_dir = *args
      ajml = Ajw2::Ajml.new
      ajml.parse(source)
      generator = Ajw2::Generator.new(ajml.application, ajml.interfaces,
                                      ajml.databases, ajml.events)
      generator.generate(out_dir)
    end
  end
end
