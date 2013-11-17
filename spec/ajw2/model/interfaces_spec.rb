require "spec_helper"

module Ajw2::Model
  describe Interfaces do
    let(:source) {
      {
        panel: {
          _isDisplay: true,
          height: 500,
          id: "rootPanel",
          left: 72,
          top: 2,
          width: 700,
          label: {
            content: "Chat Application",
            id: "label0",
            left: 27,
            top: 22
          },
          button: {
            content: "Selection",
            id: "selectButton",
            left: 369,
            top: 50
          }
        }
      }
    }

    describe "#initialize" do
      subject { Ajw2::Model::Interfaces.new(source) }
      its(:source) { should be_instance_of Hash }
    end
  end
end
