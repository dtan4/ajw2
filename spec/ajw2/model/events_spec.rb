require "spec_helper"

module Ajw2::Model
  describe Events do
    let(:source) {
      [
       {
         target: "button1",
         type: :onClick,
         action: {
           login: {
             id: "login0",
             param: [
                     { id: "param1",
                       name: "user_id",
                       type: :string,
                       value: {
                         element: "userIdTextbox",
                         func: :getValue,
                         type: :element,
                         elemType: :widget
                       }
                     }
                    ]
           },
           branch: { id: "branch1", condition: { operator: :success }  },
         then: {
             id: "then1",
             call: [
                    {
                      element: "rootFrame",
                      func: :selectPanel,
                      id: "call2",
                      param: [
                              {
                                id: "param13",
                                name: "panel",
                                type: :element,
                                element: {
                                  target: "roomSelectPanel",
                                  type: :child
                                }
                              }
                             ]
                    }
                   ]
           },
         else: { id: "else1" }
         }
       }
      ]
    }

    describe "#initialize" do
      context "with Array" do
        subject { Ajw2::Model::Events.new(source) }
        its(:source) { should be_instance_of Array }
      end

      context "with non-Array" do
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new("a") }.to raise_error
        end
      end
    end
  end
end
