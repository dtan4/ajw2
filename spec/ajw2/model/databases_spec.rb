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
                      { name: "user_id", type: :string, unique: true },
                      { name: "password", type: :password, unique: false },
                      { name: "role", type: :role, unique: false }
                     ]
         }
        ]
      }
    }

    describe "#initialize" do
      subject { Ajw2::Model::Databases.new(source) }
      its(:source) { should be_instance_of Hash }
    end
  end
end
