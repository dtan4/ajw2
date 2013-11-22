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

    describe "#render_schema" do
      before { @schema = Ajw2::Model::Databases.new(source).render_schema }

      it "should return Array" do
        expect(@schema).to be_an_instance_of Array
      end

      it "should contain 2 items" do
        expect(@schema.length).to eq 2
      end

      it "should render the schema of users table" do
        expect(@schema[0]).to eq(<<-EOS)
create_table "users", force: true do |t|
  t.string "username", null: false
  t.string "crypted_password"
  t.string "role"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
                              EOS
      end

      it "should render the schema of messages table" do
        expect(@schema[1]).to eq(<<-EOS)
create_table "messages", force: true do |t|
  t.integer "user_id", null: false
  t.string "content", null: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
                              EOS
      end
    end
  end
end
