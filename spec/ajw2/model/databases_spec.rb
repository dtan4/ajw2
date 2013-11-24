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
                      { name: "username", type: :string, unique: true, null: false },
                      { name: "password", type: :password },
                      { name: "role", type: :role  }
                     ]
         },
         {
           tablename: "messages",
           type: :server,
           property: [
                      { name: "user_id", type: :integer, unique: false, null:false },
                      { name: "content", type: :string, unique: false, null: false }
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
  t.string :username, null: false
  t.string :crypted_password
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
  end
end
