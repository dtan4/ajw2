require "pathname"

module Ajw2
  # Client between front-end file and inner logic
  class Cli
    # Parse command-line arguments and execute generating program
    # @param [Array] args command-line arguments, [source, out_dir, external_file_dir]
    def self.execute(args)
      case args.length
      when 2
        source, out_dir = *args
        external_file_dir = ""
      when 3
        source, out_dir, external_file_dir = *args
      else
        raise ArgumentError, "Invalid arguments count"
      end

      description = Ajw2::Source.new
      description.parse(source)
      generator = Ajw2::Generator.new(description.application, description.interface,
                                      description.database, description.event)
      generator.generate(out_dir, external_file_dir)
    end
  end
end
