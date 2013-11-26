require "erb"
require "fileutils"

module Ajw2
  class Generator
    attr_reader :application, :interfaces, :databases, :events

    TEMPLATE_DIR = File.expand_path("../templates", __FILE__)

    def initialize(application, interfaces, databases, events)
      @application = application
      @interfaces = interfaces
      @databases = databases
      @events = events
    end

    def generate(out_dir)
      raise Exception if Dir.exists? out_dir

      [
       "app.rb",
       "config.ru",
       "Rakefile",
       "Gemfile",
       "views/layout.slim",
       "views/index.slim",
       "config/database.yml",
       "public/js/jquery.min.js",
       "public/js/app.js"
      ].each { |file| generate_file(file, out_dir) }
    end

    private
    def padding(text, indent)
      text.each_line.map { |line| ("  " * indent) + line }.join("").chomp
    end

    def template_path(file)
      File.expand_path(file, TEMPLATE_DIR)
    end

    def destination_path(file, dir)
      File.expand_path(file, dir)
    end

    def generate_file(file, out_dir)
      dir = File.dirname(File.expand_path(file, out_dir))
      FileUtils.mkdir_p(dir) unless Dir.exists?(dir)

      if File.exists?(template_path(file))
        FileUtils.copy(template_path(file), destination_path(file, out_dir))
      elsif File.exists?(template_path(file + ".erb"))
        generate_from_erb(file, out_dir)
      else
        # TODO: raise Exception
      end
    end

    def generate_from_erb(file, dir)
      erb = ERB.new(template_path(file + ".erb"))
      open(destination_path(file, dir), "w") { |f| f.puts erb.result(binding) }
    end
  end
end
