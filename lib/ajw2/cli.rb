require "pathname"

module Ajw2
  # Client between front-end file and inner logic
  class Cli
    # Parse command-line arguments and execute generating program
    # @param [Array] args command-line arguments, [source, out_dir]
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
