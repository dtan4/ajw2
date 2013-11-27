require "spec_helper"
require "fakefs/safe"
require "fileutils"

module Ajw2
  describe Generator do
    describe "#initialize" do

    end

    describe "#generate" do
      before do
        @application = double("application",
                              render_header: "title sample",
                              name: "sample")

        @interfaces = double("interfaces",
                             render: "h1 sample")

        @databases = double("databases")

        [:development, :test, :production].each do |env|
          @databases.stub(:render_config).with(env, @application).and_return("  database: sample_#{env}")
        end

        @events = double("events")
        @outdir = File.expand_path("../tmp", __FILE__)
        @generator =
          Ajw2::Generator.new(@application, @interfaces, @databases, @events)
        # FakeFS.activate!
      end

      context "with non-existed outdir" do
        before do
          FileUtils.rm_r(@outdir) if Dir.exists?(@outdir)
          @generator.generate(@outdir)
        end

        it "should create outdir" do
          expect(Dir.exists?(@outdir)).to be_true
        end

        [
         # "app.rb",
         "config.ru",
         "Rakefile",
         "Gemfile",
         "views/layout.slim",
         "views/index.slim",
         "config/database.yml",
         "public/js/jquery.min.js",
         # "public/js/app.js"
        ].each do |path|
          it "should create #{path}" do
            expect(File.exists?(File.expand_path(path, @outdir))).to be_true
          end
        end

        it "should generate views/layout.slim" do
          expect(open(File.expand_path("views/layout.slim", @outdir)).read).to eq <<-EOS
doctype html
html
  head
    title sample
  html
    == yield
    script src="/js/jquery.min.js"
          EOS
        end

        it "should generate views/index.slim" do
          expect(open(File.expand_path("views/index.slim", @outdir)).read).to eq <<-EOS
h1 sample
          EOS
        end

        it "should generate config/database.yml" do
          expect(open(File.expand_path("config/database.yml", @outdir)).read).to eq <<-EOS
development:
  database: sample_development

test:
  database: sample_test

production:
  database: sample_production
          EOS
        end
      end

      context "with existed outdir" do
        it "should raise Exception" do
          FileUtils.mkdir_p(@outdir)
          expect {
            @generator.generate(@outdir)
          }.to raise_error
        end
      end

      after(:all) do
        # FakeFS.deactivate!
        FileUtils.rm_r(@outdir) if Dir.exists? @outdir
      end
    end
  end
end
