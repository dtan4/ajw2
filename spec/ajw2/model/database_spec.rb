require "spec_helper"

module Ajw2::Model
  describe Database do
    let(:source) do
      {
        _isDisplay: true,
        dbType: "sqlite",
        tables:
        [
          {
            name: "users",
            type: "server",
            fields: [
              { name: "username", type: "string", nullable: false },
              { name: "password", type: "password", nullable: true },
              { name: "role", type: "role", nullable: true }
            ]
          },
          {
            name: "messages",
            type: "server",
            fields: [
              { name: "user_id", type: "integer", nullable: false },
              { name: "content", type: "string", nullable: false }
            ]
          }
        ]
      }
    end

    let(:invalid_source) do
      {}
    end

    let(:database) do
      described_class.new(source)
    end

    describe "#initialize" do
      let(:database) do
        described_class.new(arg)
      end

      context "with Hash" do
        let(:arg) do
          source
        end

        it "should be an instance of Database" do
          expect(database).to be_a described_class
        end
      end

      context "with non-Hash" do
        let(:arg) do
          "a"
        end

        it "should to raise ArgumentError" do
          expect do
            database
          end.to raise_error ArgumentError, "Database section must be a Hash"
        end
      end
    end

    describe "#render_migration" do
      let(:render_migration) do
        database.render_migration
      end

      context "with valid source" do
        it "has 2 items" do
          expect(render_migration.size).to eq(2)
        end

        it "should render the setup migration" do
          expect(render_migration[0][:up]).to eq(<<-EOS)
create_table :users do |t|
  t.string :username
  t.string :encrypted_password
  t.string :role
  t.timestamps
end
                                           EOS
        end

        it "should render the teardown migration" do
          expect(render_migration[0][:down]).to eq(<<-EOS)
drop_table :users
                                             EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_migration
          end.to raise_error RuntimeError, "/database/tables is not found"
        end
      end
    end

    describe "#render_definition" do
      let(:render_definition) do
        database.render_definition
      end

      context "with valid source" do
        it "has 2 items" do
          expect(render_definition.size).to eq(2)
        end

        it "should render the definition" do
          expect(render_definition[0]).to eq(<<-EOS)
class User < ActiveRecord::Base
  validates_presence_of :username
end
                                      EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_definition
          end.to raise_error RuntimeError, "/database/tables is not found"
        end
      end
    end

    describe "#render_config" do
      let(:application) do
        double("application", name: "sample")
      end

      let(:type) do
        :development
      end

      let(:render_config) do
        database.render_config(type, application)
      end

      context "when dbType is mysql" do
        let(:source) do
          { dbType: "mysql" }
        end

        it "should call Application#name" do
          expect(application).to receive(:name)
          render_config
        end

        it "should render the config" do
          expect(render_config).to eq <<-EOS
adapter: mysql2
encoding: utf8
reconnect: true
database: sample_development
pool: 5
username: root
password:
host: localhost
sock: /tmp/mysql.sock
            EOS
        end
      end

      context "when dbType is postgres" do
        let(:source) do
          { dbType: "postgres" }
        end

        it "should call Application#name" do
          expect(application).to receive(:name)
          render_config
        end

        it "should render the config" do
          expect(render_config).to eq <<-EOS
adapter: postgresql
database: sample_development
username: root
password:
host: localhost
port: 5432
            EOS
        end
      end

      context "when dbType is sqlite" do
        let(:source) do
          { dbType: "sqlite" }
        end

        it "should not call Application#name" do
          expect(application).not_to receive(:name)
          render_config
        end

        it "should render the config" do
          expect(render_config).to eq <<-EOS
adapter: sqlite3
database: db/development.sqlite3
pool: 5
timeout: 5000
            EOS
        end
      end

      context "when dbType is unknown" do
        let(:source) do
          { dbType: "hogehoge" }
        end

        it "should not call Application#name" do
          expect(application).not_to receive(:name)
          render_config
        end

        it "should render the config" do
          expect(render_config).to eq <<-EOS
adapter: sqlite3
database: db/development.sqlite3
pool: 5
timeout: 5000
            EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_config
          end.to raise_error RuntimeError, "/database/dbType is not found"
        end
      end
    end

    describe "#render_database_gem" do
      let(:application) do
        double("application", name: "sample")
      end

      let(:render_database_gem) do
        database.render_database_gem
      end

      context "when dbType is mysql" do
        let(:source) do
          { dbType: "mysql" }
        end

        it "should render gem requirement" do
          expect(render_database_gem).to be == 'gem "mysql2"'
        end
      end

      context "when dbType is postgres" do
        let(:source) do
          { dbType: "postgres" }
        end

        it "should render gem requirement" do
          expect(render_database_gem).to be == 'gem "pg"'
        end
      end

      context "when dbType is sqlite" do
        let(:source) do
          { dbType: "sqlite" }
        end

        it "should render gem requirement" do
          expect(render_database_gem).to be == 'gem "sqlite3"'
        end
      end

      context "when dbType is unknown" do
        let(:source) do
          { dbType: "hoge" }
        end

        it "should render gem requirement" do
          expect(render_database_gem).to be == 'gem "sqlite3"'
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_database_gem
          end.to raise_error RuntimeError, "/database/dbType is not found"
        end
      end
    end
  end
end
