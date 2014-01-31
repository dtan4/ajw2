require "optparse"

module Ajw2
  # Client between front-end file and inner logic
  class Cli
    USAGE_BANNER = "Usage: ajw2 SOURCE_FILE [options]"

    # Parse command-line arguments and execute generating program
    # @param [Array] args command-line arguments, [source_path, "-o", out_dir, "-e", external_resource_dir]
    def self.execute(args)
      out_dir = ""
      external_resource_dir = ""

      OptionParser.new(USAGE_BANNER) do |opt|
        opt.version = Ajw2::VERSION
        opt.on("-o", "--output OUTPUT_DIR", "output directory") { |v| out_dir = v }
        opt.on("-e", "--external EXTERNAL_RESOURCE_DIR", "external resource directory") { |v| external_resource_dir = v }
        opt.permute!(args)
      end

      raise ArgumentError if args.length == 0

      source = Ajw2::Source.new
      source.parse_file(args.shift)
      generator = Ajw2::Generator.new(source.application, source.interface,
                                      source.database, source.event)
      generator.generate(out_dir, external_resource_dir)
    end
  end
end
