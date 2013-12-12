require "erb"
require "fileutils"
require "ajw2/util"

module Ajw2
  class Generator
    include Ajw2::Util

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

      begin
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

        generate_migration_files(out_dir)
      rescue Exception => e
        $stderr.puts "#{e.class}: #{e.message}"
        FileUtils.rm_rf(out_dir) if Dir.exists?(out_dir)
      end
    end

    private

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
      erb = ERB.new(open(template_path(file + ".erb")).read, nil, "-")
      open(destination_path(file, dir), "w") { |f| f.puts erb.result(binding) }
    end

    def generate_migration_files(dir)
      FileUtils.mkdir_p(File.expand_path("db/migrate", dir))

      @databases.render_migration.each_with_index do |migration, idx|
        erb = ERB.new(open(template_path("db/migrate/migration.rb.erb")).read)
        file = "db/migrate/" << "%.3d" % (idx + 1) << "_create_#{migration[:tablename]}.rb"
        open(destination_path(file, dir), "w") { |f| f.puts erb.result(binding) }
      end
    end
  end
end
