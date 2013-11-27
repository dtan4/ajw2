require "spec_helper"
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

        @databases = double("databases",
                            render_migration: [
                                               {
                                                tablename: "users",
                                                up: (<<-EOS),
create_table :users do |t|
  t.string :name
  t.string :password
end
                                                EOS
                                                down: "drop_table :users"
                                               },
                                               {
                                                tablename: "messages",
                                                up: (<<-EOS),
create_table :messages do |t|
  t.integer :user_id
  t.string :message
end
                                                EOS
                                                down: "drop_table :messages"
                                               }
                                              ],
                            render_definition: [
                                                (<<-EOS),
class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :password
end
EOS
                                                (<<-EOS),
class Message < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :message
end
EOS
                                               ])

        [:development, :test, :production].each do |env|
          @databases.stub(:render_config).with(env, @application).and_return("database: sample_#{env}")
        end

        @events = double("events")
        @outdir = File.expand_path("../tmp", __FILE__)
        @generator =
          Ajw2::Generator.new(@application, @interfaces, @databases, @events)
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
         # "public/js/app.js",
        ].each do |path|
          it "should create #{path}" do
            expect(File.exists?(File.expand_path(path, @outdir))).to be_true
          end
        end

        it "should generate app.rb" do
          expect(open(File.expand_path("app.rb", @outdir)).read).to eq <<-EOS
class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :password
end

class Message < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :message
end

class App < Sinatra::Base
  configure do
    register Sinatra::ActiveRecordExtension
    set :sockets, []
    use Rack::Session::Cookie, expire_after: 3600, secret: "salt"
    Slim::Engine.default_options[:pretty] = true
  end

  get "/" do
    if !request.websocket?
      slim :index
    else

    end
  end
end
          EOS
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

        it "should generate db/migrate/001_create_users.rb" do
          expect(open(File.expand_path("db/migrate/001_create_users.rb", @outdir)).read).to eq <<-EOS
class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
      t.string :password
    end
  end

  def down
    drop_table :users
  end
end
          EOS
        end

        it "should generate db/migrate/002_create_messages.rb" do
          expect(open(File.expand_path("db/migrate/002_create_messages.rb", @outdir)).read).to eq <<-EOS
class CreateMessages < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.integer :user_id
      t.string :message
    end
  end

  def down
    drop_table :messages
  end
end
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

      after do
        FileUtils.rm_r(@outdir) if Dir.exists? @outdir
      end
    end
  end
end
