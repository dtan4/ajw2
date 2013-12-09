require "spec_helper"

module Ajw2::Model
  describe Databases do
    let(:source) {
      {
        _isDisplay: true,
        dbType: "sqlite",
        database:
        [
         {
           tablename: "users",
           type: "server",
           property: [
                      { name: "username", type: "string", null: false },
                      { name: "password", type: "password", null: true },
                      { name: "role", type: "role", null: true }
                     ]
         },
         {
           tablename: "messages",
           type: "server",
           property: [
                      { name: "user_id", type: "integer", null: false },
                      { name: "content", type: "string", null: false }
                     ]
         }
        ]
      }
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Databases.new(source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should to raise ArgumentError" do
          expect { Ajw2::Model::Databases.new("a") }.to raise_error ArgumentError,
            "Databases section must be a Hash"
        end
      end
    end

    describe "#render_migration" do
      context "with valid source" do
        subject { Ajw2::Model::Databases.new(source).render_migration }
        it { should be_an_instance_of Array }
        it { should have(2).items }

        it "should render the setup migration" do
          expect(subject[0][:up]).to eq(<<-EOS)
create_table :users do |t|
  t.string :username
  t.string :encrypted_password
  t.string :role
  t.timestamps
end
                                           EOS
        end

        it "should render the teardown migration" do
          expect(subject[0][:down]).to eq(<<-EOS)
drop_table :users
                                             EOS
        end
      end

      context "with invalid source" do
        it "should raise Exception" do
          expect { Ajw2::Model::Databases.new({}).render_migration }.to raise_error RuntimeError, "/databases/database is not found"
        end
      end
    end

    describe "#render_definition" do
      context "with valid source" do
        subject { Ajw2::Model::Databases.new(source).render_definition }
        it { should be_an_instance_of Array }
        it { should have(2).items }

        it "should render the definition" do
          expect(subject[0]).to eq(<<-EOS)
class User < ActiveRecord::Base
  validates_presence_of :username
end
                                      EOS
        end
      end

      context "with invalid source" do
        it "should raise Exception" do
          expect { Ajw2::Model::Databases.new({}).render_definition }.to raise_error RuntimeError, "/databases/database is not found"
        end
      end
    end

    describe "#render_config" do
      before do
        @application = double("application", name: "sample")
      end

      context "when dbType is mysql" do
        subject { Ajw2::Model::Databases.new({ dbType: "mysql" }).render_config(:development, @application) }
        it { should be_an_instance_of String }

        it "should call Application#name" do
          expect(@application).to receive(:name)
          subject
        end

        it "should render the config" do
          expect(subject).to eq <<-EOS
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
        subject { Ajw2::Model::Databases.new({ dbType: "postgres" }).render_config(:development, @application) }
        it { should be_an_instance_of String }

        it "should call Application#name" do
          expect(@application).to receive(:name)
          subject
        end

        it "should render the config" do
          expect(subject).to eq <<-EOS
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
        subject { Ajw2::Model::Databases.new({ dbType: "sqlite" }).render_config(:development, @application) }
        it { should be_an_instance_of String }

        it "should not call Application#name" do
          expect(@application).not_to receive(:name)
          subject
        end

        it "should render the config" do
          expect(subject).to eq <<-EOS
adapter: sqlite3
database: db/development.sqlite3
pool: 5
timeout: 5000
            EOS
        end
      end

      context "when dbType is unknown" do
        subject { Ajw2::Model::Databases.new({ dbType: "hogehoge" }).render_config(:development, @application) }
        it { should be_an_instance_of String }

        it "should not call Application#name" do
          expect(@application).not_to receive(:name)
          subject
        end

        it "should render the config" do
          expect(subject).to eq <<-EOS
adapter: sqlite3
database: db/development.sqlite3
pool: 5
timeout: 5000
            EOS
        end
      end

      context "with invalid source" do
        it "should raise Exception" do
          expect { Ajw2::Model::Databases.new({}).render_config(:development, @application) }.to raise_error RuntimeError, "/databases/dbType is not found"
        end
      end
    end
  end
end
