require "spec_helper"

module Ajw2::Model
  describe Interfaces do
    let(:source) {
      [
       {
         type: :panel,
         _isDisplay: true,
         height: 500,
         id: "rootPanel",
         left: 72,
         top: 2,
         width: 700,
         children: [
                    {
                      type: :label,
                      content: "Chat Application",
                      id: "label0",
                      left: 27,
                      top: 22
                    },
                    {
                      type: :button,
                      content: "Selection",
                      id: "selectButton",
                      left: 369,
                      top: 50
                    }
                   ]
       }
      ]
    }

    describe "#initialize" do
      subject { Ajw2::Model::Interfaces.new(source) }
      its(:source) { should be_instance_of Array }
    end
  end
end
