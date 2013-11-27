require "spec_helper"

module Ajw2::Model
  describe Databases do
    let(:source) {
      {
        _isDisplay: true,
        dbType: :sqlite,
        database:
        [
         {
           tablename: "users",
           type: :server,
           property: [
                      { name: "username", type: :string, null: false },
                      { name: "password", type: :password },
                      { name: "role", type: :role  }
                     ]
         },
         {
           tablename: "messages",
           type: :server,
           property: [
                      { name: "user_id", type: :integer, null: false },
                      { name: "content", type: :string, null: false }
                     ]
         }
        ]
      }
    }

    describe "#initialize" do
      subject { Ajw2::Model::Databases.new(source) }
      its(:source) { should be_instance_of Hash }
    end

    describe "#render_migration" do
      before { @migration = Ajw2::Model::Databases.new(source).render_migration }

      it "should return Array" do
        expect(@migration).to be_an_instance_of Array
      end

      it "should have 2 item" do
        expect(@migration.length).to eq 2
      end

      it "should render the setup migration" do
        expect(@migration[0][:up]).to eq(<<-EOS)
create_table :users do |t|
  t.string :username
  t.string :encrypted_password
  t.string :role
  t.timestamps
end
                                         EOS
      end

      it "should render the teardown migration" do
        expect(@migration[0][:down]).to eq(<<-EOS)
drop_table :users
                                         EOS
      end
    end

    describe "#render_definition" do
      before { @definition = Ajw2::Model::Databases.new(source).render_definition }

      it "should return Array" do
        expect(@definition).to be_an_instance_of Array
      end

      it "should have 2 item" do
        expect(@definition.length).to eq 2
      end

      it "should render the definition" do
        expect(@definition[0]).to eq(<<-EOS)
class User < ActiveRecord::Base
  validates_presence_of :username
end
                                     EOS
      end
    end

    describe "#render_config" do
      before do
        @application = double("application", name: "sample")
      end

      shared_examples_for "valid dbType" do
        it "should return Hash" do
          expect(@config).to be_an_instance_of String
        end
      end

      context "when dbType is mysql" do
        before do
          @config =
            Ajw2::Model::Databases.new({ dbType: :mysql }).render_config(:development, @application)
        end

        it_behaves_like "valid dbType"

        it "should call Application#name" do
          expect(@application).to receive(:name)
          Ajw2::Model::Databases.new({ dbType: :mysql }).render_config(:development, @application)
        end

        it "should render the config" do
          expect(@config).to eq <<-EOS
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
        before do
          @config =
            Ajw2::Model::Databases.new({ dbType: :postgres }).render_config(:development, @application)
        end

        it_behaves_like "valid dbType"

        it "should call Application#name" do
          expect(@application).to receive(:name)
          Ajw2::Model::Databases.new({ dbType: :postgres }).render_config(:development, @application)
        end

        it "should render the config" do
          expect(@config).to eq <<-EOS
adapter: postgresql
database: sample_development
username: root
password:
host: localhost
port: 5432
            EOS
        end
      end

      shared_examples_for "sqlite" do
        it "should render the config" do
          expect(@config).to eq <<-EOS
adapter: sqlite3
database: db/development.sqlite3
pool: 5
timeout: 5000
            EOS
        end
      end

      context "when dbType is sqlite" do
        before do
          @config =
            Ajw2::Model::Databases.new({ dbType: :sqlite }).render_config(:development, @application)
        end

        it_behaves_like "valid dbType"

        it "should not call Application#name" do
          expect(@application).not_to receive(:name)
          Ajw2::Model::Databases.new({ dbType: :sqlite }).render_config(:development, @application)
        end

        it_behaves_like "sqlite"
      end

      context "when dbType is unknown" do
        before do
          @config =
            Ajw2::Model::Databases.new({ dbType: :hogehoge }).render_config(:development, @application)
        end

        it_behaves_like "valid dbType"

        it "should not call Application#name" do
          expect(@application).not_to receive(:name)
          Ajw2::Model::Databases.new({ dbType: :hogehoge }).render_config(:development, @application)
        end

        it_behaves_like "sqlite"
      end
    end
  end
end
