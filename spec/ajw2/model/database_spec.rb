require "spec_helper"

module Ajw2::Model
  describe Database do
    let(:source) {
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
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Database.new(source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should to raise ArgumentError" do
          expect { Ajw2::Model::Database.new("a") }.to raise_error ArgumentError,
            "Database section must be a Hash"
        end
      end
    end

    describe "#render_migration" do
      context "with valid source" do
        subject { Ajw2::Model::Database.new(source).render_migration }
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
          expect { Ajw2::Model::Database.new({}).render_migration }.to raise_error RuntimeError, "/database/tables is not found"
        end
      end
    end

    describe "#render_definition" do
      context "with valid source" do
        subject { Ajw2::Model::Database.new(source).render_definition }
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
          expect { Ajw2::Model::Database.new({}).render_definition }.to raise_error RuntimeError, "/database/tables is not found"
        end
      end
    end

    describe "#render_config" do
      before do
        @application = double("application", name: "sample")
      end

      context "when dbType is mysql" do
        subject { Ajw2::Model::Database.new({ dbType: "mysql" }).render_config(:development, @application) }
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
        subject { Ajw2::Model::Database.new({ dbType: "postgres" }).render_config(:development, @application) }
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
        subject { Ajw2::Model::Database.new({ dbType: "sqlite" }).render_config(:development, @application) }
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
        subject { Ajw2::Model::Database.new({ dbType: "hogehoge" }).render_config(:development, @application) }
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
          expect { Ajw2::Model::Database.new({}).render_config(:development, @application) }.to raise_error RuntimeError, "/database/dbType is not found"
        end
      end
    end

    describe "#render_database_gem" do
      before do
        @application = double("application", name: "sample")
      end

      context "when dbType is mysql" do
        subject { Ajw2::Model::Database.new({ dbType: "mysql" }).render_database_gem }
        it { should be_an_instance_of String }

        it "should render gem requirement" do
          expect(subject).to be == 'gem "mysql2"'
        end
      end

      context "when dbType is postgres" do
        subject { Ajw2::Model::Database.new({ dbType: "postgres" }).render_database_gem }
        it { should be_an_instance_of String }

        it "should render gem requirement" do
          expect(subject).to be == 'gem "pg"'
        end
      end

      context "when dbType is sqlite" do
        subject { Ajw2::Model::Database.new({ dbType: "sqlite" }).render_database_gem }
        it { should be_an_instance_of String }

        it "should render gem requirement" do
          expect(subject).to be == 'gem "sqlite3"'
        end
      end

      context "when dbType is unknown" do
        subject { Ajw2::Model::Database.new({ dbType: "hogehoge" }).render_database_gem }
        it { should be_an_instance_of String }

        it "should render gem requirement" do
          expect(subject).to be == 'gem "sqlite3"'
        end
      end

      context "with invalid source" do
        it "should raise Exception" do
          expect { Ajw2::Model::Database.new({}).render_config(:development, @application) }.to raise_error RuntimeError, "/database/dbType is not found"
        end
      end
    end
  end
end
