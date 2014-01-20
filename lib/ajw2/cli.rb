require "pathname"

module Ajw2
  # Client between front-end file and inner logic
  class Cli
    # Parse command-line arguments and execute generating program
    # @param [Array] args command-line arguments, [source_path, out_dir, external_file_dir]
    def self.execute(args)
      case args.length
      when 2
        source_path, out_dir = *args
        external_file_dir = ""
      when 3
        source_path, out_dir, external_file_dir = *args
      else
        raise ArgumentError, "Invalid arguments count"
      end

      source = Ajw2::Source.new
      source.parse_file(source_path)
      generator = Ajw2::Generator.new(source.application, source.interface,
                                      source.database, source.event)
      generator.generate(out_dir, external_file_dir)
    end
  end
end
