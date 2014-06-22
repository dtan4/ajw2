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
        @external_file_dir = File.expand_path("../ext_dir_tmp", __FILE__)
        @application = double("application",
                              render_header: "title sample",
                              render_css_include: RENDER_CSS_INCLUDE,
                              render_js_include: RENDER_JS_INCLUDE,
                              name: "sample")
        allow(@application).to receive(:external_local_files).with(:js, @external_file_dir).and_return([])
        allow(@application).to receive(:external_local_files).with(:css, @external_file_dir).and_return([])

        @interface = double("interface",
                            render: "h1 sample")

        @database = double("database",
                           render_migration: RENDER_MIGRATION,
                           render_definition: RENDER_DEFINITION,
                           render_database_gem: "sqlite")

        [:development, :test, :production].each do |env|
          allow(@database).to receive(:render_config).with(env, @application).and_return("database: sample_#{env}")
        end

        @outdir = File.expand_path("../tmp", __FILE__)
      end

      context "with non-existed outdir" do
        shared_examples_for "generates successfully" do
          it "should create outdir" do
            expect(Dir.exist?(@outdir)).to be true
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
              expect(File.exist?(File.expand_path(path, @outdir))).to be true
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

        context "with Ajax event and Websocket event" do
          before do
            FileUtils.rm_r(@outdir) if Dir.exist?(@outdir)

            @event = double("event",
                            render_rb_ajax: RENDER_RB_AJAX,
                            render_rb_realtime: RENDER_RB_REALTIME,
                            render_js_ajax: RENDER_JS_AJAX,
                            render_js_realtime: RENDER_JS_REALTIME,
                            render_js_onmessage: RENDER_JS_ONMESSAGE)
            @generator =
              Ajw2::Generator.new(@application, @interface, @database, @event)
            @generator.generate(@outdir, @external_file_dir)
          end

          it_behaves_like "generates successfully"

          it "should generate app.rb" do
            expect(open(File.expand_path("app.rb", @outdir)).read).to eq APP_RB
          end

          it "should generate public/js/app.js" do
            expect(open(File.expand_path("public/js/app.js", @outdir)).read).to eq APP_JS
          end
        end

        context "with Ajax event only" do
          before do
            FileUtils.rm_r(@outdir) if Dir.exist?(@outdir)

            @event = double("event",
                            render_rb_ajax: RENDER_RB_AJAX,
                            render_rb_realtime: [],
                            render_js_ajax: RENDER_JS_AJAX,
                            render_js_realtime: [],
                            render_js_onmessage: [])
            @generator =
              Ajw2::Generator.new(@application, @interface, @database, @event)
            @generator.generate(@outdir, @external_file_dir)
          end

          it_behaves_like "generates successfully"

          it "should generate app.rb" do
            expect(open(File.expand_path("app.rb", @outdir)).read).to eq APP_RB_AJAX_ONLY
          end

          it "should generate public/js/app.js" do
            expect(open(File.expand_path("public/js/app.js", @outdir)).read).to eq APP_JS_AJAX_ONLY
          end
        end

        context "with WebSocket event only" do
          before do
            FileUtils.rm_r(@outdir) if Dir.exist?(@outdir)

            @event = double("event",
                            render_rb_ajax: [],
                            render_rb_realtime: RENDER_RB_REALTIME,
                            render_js_ajax: [],
                            render_js_realtime: RENDER_JS_REALTIME,
                            render_js_onmessage: RENDER_JS_ONMESSAGE)
            @generator =
              Ajw2::Generator.new(@application, @interface, @database, @event)
            @generator.generate(@outdir, @external_file_dir)
          end

          it_behaves_like "generates successfully"

          it "should generate app.rb" do
            expect(open(File.expand_path("app.rb", @outdir)).read).to eq APP_RB_REALTIME_ONLY
          end

          it "should generate public/js/app.js" do
            expect(open(File.expand_path("public/js/app.js", @outdir)).read).to eq APP_JS_REALTIME_ONLY
          end
        end

        context "with no event" do
          before do
            FileUtils.rm_r(@outdir) if Dir.exist?(@outdir)

            @event = double("event",
                            render_rb_ajax: [],
                            render_rb_realtime: [],
                            render_js_ajax: [],
                            render_js_realtime: [],
                            render_js_onmessage: [])
            @generator =
              Ajw2::Generator.new(@application, @interface, @database, @event)
            @generator.generate(@outdir, @external_file_dir)
          end

          it_behaves_like "generates successfully"

          it "should generate app.rb" do
            expect(open(File.expand_path("app.rb", @outdir)).read).to eq APP_RB_NOEVENT
          end

          it "should generate public/js/app.js" do
            expect(open(File.expand_path("public/js/app.js", @outdir)).read).to eq APP_JS_NOEVENT
          end
        end

        context "with external resource" do
          before do
            FileUtils.rm_r(@outdir) if Dir.exist?(@outdir)

            @application_with_ext = double("application",
                                           render_header: "title sample",
                                           render_css_include: RENDER_CSS_INCLUDE,
                                           render_js_include: RENDER_JS_INCLUDE,
                                           name: "sample")
            allow(@application_with_ext).to receive(:external_local_files)
            .with(:js, @external_file_dir).and_return([File.expand_path("external.js", @external_file_dir)])
            allow(@application_with_ext).to receive(:external_local_files)
            .with(:css, @external_file_dir).and_return([File.expand_path("external.css", @external_file_dir)])

            FileUtils.mkdir_p(@external_file_dir)
            open(File.expand_path("external.js", @external_file_dir), "w") { |f| f.puts "hoge" }
            open(File.expand_path("external.css", @external_file_dir), "w") { |f| f.puts "hoge" }

            @database_with_ext = double("database",
                                        render_migration: RENDER_MIGRATION,
                                        render_definition: RENDER_DEFINITION,
                                        render_database_gem: "sqlite")

            [:development, :test, :production].each do |env|
              allow(@database_with_ext).to receive(:render_config).with(env, @application_with_ext).and_return("database: sample_#{env}")
            end

            @event = double("event",
                            render_rb_ajax: [],
                            render_rb_realtime: [],
                            render_js_ajax: [],
                            render_js_realtime: [],
                            render_js_onmessage: [])

            @generator =
              Ajw2::Generator.new(@application_with_ext, @interface, @database_with_ext, @event)
            @generator.generate(@outdir, @external_file_dir)
          end

          it_behaves_like "generates successfully"

          it "should include external.js" do
            expect(File.exist?(File.expand_path("public/js/external.js", @outdir))).to be true
          end

          it "should include external.css" do
            expect(File.exist?(File.expand_path("public/css/external.css", @outdir))).to be true
          end
        end

        context "with invalid source" do
          before do
            FileUtils.rm_r(@outdir) if Dir.exist?(@outdir)

            @database = double("database",
                               render_migration: "hoge",
                               render_definition: "hoge")
            @generator =
              Ajw2::Generator.new(@application, @interface, @database, @event)
          end

          subject { @generator.generate(@outdir, @external_file_dir) }

          it "should raise Exception" do
            expect { @generator.generate(@outdir, @external_file_dir) }.to raise_error
          end

          it "should not create outdir" do
            begin
              subject
            rescue
              expect(Dir.exist? @outdir).to be_falsey
            end
          end
        end
      end

      context "with existed outdir" do
        it "should raise Exception" do
          FileUtils.mkdir_p(@outdir)
          expect {
            @generator.generate(@outdir, @external_file_dir)
          }.to raise_error
        end
      end

      after do
        FileUtils.rm_r(@outdir) if Dir.exist? @outdir
        FileUtils.rm_r(@external_file_dir) if Dir.exist? @external_file_dir
      end
    end
  end
end
