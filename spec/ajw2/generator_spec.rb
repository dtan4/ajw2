require "spec_helper"
require "fileutils"

module Ajw2
  describe Generator do
    describe "#initialize" do

    end

    describe "#generate" do
      before(:all) do
        load File.expand_path("../../fixtures/generator_fixtures.rb", __FILE__)
      end

      before do
        @application = double("application",
                              render_header: "title sample",
                              render_css_include: RENDER_CSS_INCLUDE,
                              render_js_include: RENDER_JS_INCLUDE,
                              name: "sample")

        @interfaces = double("interfaces",
                             render: "h1 sample")

        @databases = double("databases",
                            render_migration: RENDER_MIGRATION,
                            render_definition: RENDER_DEFINITION)

        [:development, :test, :production].each do |env|
          @databases.stub(:render_config).with(env, @application).and_return("database: sample_#{env}")
        end

        @outdir = File.expand_path("../tmp", __FILE__)
      end

      shared_examples_for "generates successfully" do
        it "should create outdir" do
          expect(Dir.exists?(@outdir)).to be_true
        end

        [
         "app.rb",
         "config.ru",
         "Rakefile",
         "Gemfile",
         "views/layout.slim",
         "views/index.slim",
         "config/database.yml",
         "db/migrate/001_create_users.rb",
         "db/migrate/002_create_messages.rb",
         "public/js/jquery.min.js",
         "public/js/app.js"
        ].each do |path|
          it "should create #{path}" do
            expect(File.exists?(File.expand_path(path, @outdir))).to be_true
          end
        end

        it "should generate views/layout.slim" do
          expect(open(File.expand_path("views/layout.slim", @outdir)).read).to eq LAYOUT_SLIM
        end

        it "should generate views/index.slim" do
          expect(open(File.expand_path("views/index.slim", @outdir)).read).to eq INDEX_SLIM
        end

        it "should generate config/database.yml" do
          expect(open(File.expand_path("config/database.yml", @outdir)).read).to eq DATABASE_YML
        end

        it "should generate db/migrate/001_create_users.rb" do
          expect(open(File.expand_path("db/migrate/001_create_users.rb", @outdir)).read).to eq CREATE_USERS_RB
        end

        it "should generate db/migrate/002_create_messages.rb" do
          expect(open(File.expand_path("db/migrate/002_create_messages.rb", @outdir)).read).to eq CREATE_MESSAGES_RB
        end
      end

      context "with non-existed outdir" do
        before do
          FileUtils.rm_r(@outdir) if Dir.exists?(@outdir)

          @events = double("events",
                         render_rb_ajax: RENDER_RB_AJAX,
                         render_rb_realtime: RENDER_RB_REALTIME,
                         render_js_ajax: RENDER_JS_AJAX,
                         render_js_realtime: RENDER_JS_REALTIME,
                         render_js_onmessage: RENDER_JS_ONMESSAGE)
          @generator =
            Ajw2::Generator.new(@application, @interfaces, @databases, @events)
          @generator.generate(@outdir)
        end

        it_behaves_like "generates successfully"

        it "should generate app.rb" do
          expect(open(File.expand_path("app.rb", @outdir)).read).to eq APP_RB
        end

        it "should generate public/js/app.js" do
          expect(open(File.expand_path("public/js/app.js", @outdir)).read).to eq APP_JS
        end
      end

      context "with Ajax-only events" do
        before do
          FileUtils.rm_r(@outdir) if Dir.exists?(@outdir)

          @events = double("events",
                         render_rb_ajax: RENDER_RB_AJAX,
                         render_rb_realtime: [],
                         render_js_ajax: RENDER_JS_AJAX,
                         render_js_realtime: [],
                         render_js_onmessage: [])
          @generator =
            Ajw2::Generator.new(@application, @interfaces, @databases, @events)
          @generator.generate(@outdir)
        end

        it_behaves_like "generates successfully"

        it "should generate app.rb" do
          expect(open(File.expand_path("app.rb", @outdir)).read).to eq APP_RB_AJAX_ONLY
        end

        it "should generate public/js/app.js" do
          expect(open(File.expand_path("public/js/app.js", @outdir)).read).to eq APP_JS_AJAX_ONLY
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

      after do
        FileUtils.rm_r(@outdir) if Dir.exists? @outdir
      end
    end
  end
end
