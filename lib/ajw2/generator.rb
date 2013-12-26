require "erb"
require "fileutils"
require "ajw2/util"

module Ajw2
  # Generate source code from model description
  class Generator
    include Ajw2::Util

    attr_reader :application, :interfaces, :databases, :events

    TEMPLATE_DIR = File.expand_path("../templates", __FILE__)

    # Initializer
    # @param [Ajw2::Model::Application] application Application settings generator
    # @param [Ajw2::Model::Interfaces] interfaces Interfaces model generator
    # @param [Ajw2::Model::Databases] databases Databases model generator
    # @param [Ajw2::Model::Events] events Events settings generator
    def initialize(application, interfaces, databases, events)
      @application = application
      @interfaces = interfaces
      @databases = databases
      @events = events
    end

    # Execute generation
    # @param [String] out_dir directory path to output files
    def generate(out_dir, external_file_dir)
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
        copy_external_files(out_dir, external_file_dir)
      rescue Exception => e
        FileUtils.rm_rf(out_dir) if Dir.exists?(out_dir)
        raise e
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

    def copy_external_files(outdir, external_file_dir)
      [:css, :js].each do |type|
        dir = File.expand_path("public/#{type.to_s}", outdir)
        FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
        FileUtils.cp(@application.external_files(type).map do |file|
                       File.expand_path(file, external_file_dir)
                     end, dir)
      end
    end
  end
end
