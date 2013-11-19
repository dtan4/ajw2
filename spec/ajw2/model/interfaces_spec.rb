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
                      value: "Chat Application",
                      id: "label0",
                      left: 27,
                      top: 22
                    },
                    {
                      type: :text,
                      id: "userIdTextbox",
                      placeholder: "user name",
                      left: 132,
                      top: 29,
                      width: 100
                    },
                    {
                      type: :button,
                      value: "Selection",
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

    describe "#render" do
      context "with valid source" do
        before { @result = Ajw2::Model::Interfaces.new(source).render }

        it "should return String" do
          expect(@result).to be_an_instance_of String
        end

        it "should return Slim template" do
          expect(@result).to eq(<<-EOS)
#rootPanel style="position:absolute; left:72; top:2; width:700px;"
  label#label0 style="position:absolute; left:27; top:22;" Chat Application
  input#userIdTextbox type="text" placeholder="user name" style="position:absolute; left:132; top:29; width:100px;"
  button#selectButton style="position:absolute; left:369; top:50;" Selection
EOS
        end
      end

      context "with invalid source" do
        @invalid_sources = [
                            [{ type: :panel }],
                            [{ id: "hoge" }]
                           ]

        @invalid_sources.each do |src|
          it "should raise Exception" do
            expect {
              puts Ajw2::Model::Interfaces.new(src).render
            }.to raise_error ArgumentError
          end
        end
      end
    end
  end
end
