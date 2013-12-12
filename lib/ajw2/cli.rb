require "pathname"

module Ajw2
  class Cli
    def self.execute(args)
      source, out_dir = *args
      description = Ajw2::Description.new
      description.parse(source)
      generator = Ajw2::Generator.new(description.application, description.interfaces,
                                      description.databases, description.events)
      generator.generate(out_dir)
    end
  end
end
