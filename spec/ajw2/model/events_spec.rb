require "spec_helper"

module Ajw2::Model
  describe Events do
    let(:simple_source) {
      {
       events:
       [
        {
         id: "event01",
         target: "submitBtn",
         type: "onClick",
         realtime: false,
         params: [
                  {
                   name: "message", type: "string",
                   value: {
                           element: "messageTextBox",
                           func: "getValue",
                           type: "element"
                          }
                  }
                 ],
         interfaces: [
                      {
                       id: "if01",
                       element: "messageLabel",
                       func: "setValue", type: "element",
                       params: [
                                {
                                 name: "message",
                                 type: "string"
                                }
                               ]

                      }
                     ],
         databases: [
                     {
                      id: "db01",
                      database: "messages",
                      func: "create",
                      params: [
                               {
                                name: "message",
                                type: "string"
                               }
                              ]
                     }
                    ]
        }
       ]
      }
    }

    let(:complex_source) {
      {
       events:
       [
        {
         target: "button1",
         type: "onClick",
         action: {
                  login: {
                          id: "login0",
                          param: [
                                  { id: "param1",
                                   name: "user_id",
                                   type: "string",
                                   value: {
                                           element: "userIdTextbox",
                                           func: "getValue",
                                           type: "element",
                                           elemType: "widget"
                                          }
                                  }
                                 ]
                         },
                  branch: { id: "branch1", condition: { operator: "success" }  },
                  then: {
                         id: "then1",
                         call: [
                                {
                                 element: "rootFrame",
                                 func: "selectPanel",
                                 id: "call2",
                                 param: [
                                         {
                                          id: "param13",
                                          name: "panel",
                                          type: "element",
                                          element: {
                                                    target: "roomSelectPanel",
                                                    type: "child"
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
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Events.new(simple_source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new("a") }.to raise_error ArgumentError,
            "Events section must be a Hash"
        end
      end
    end

    describe "#render_rb" do
      context "with valid source" do
        subject { Ajw2::Model::Events.new(simple_source).render_rb }
        it { should be_an_instance_of Array }
        it { should have(1).item }

        it "should render the Sinatra source" do
          expect(subject[0]).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = {}
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  db01.save
  response[:message] = message
  response.to_json
end
                                   EOS
        end
      end
    end

    describe "#render_js" do

    end
  end
end
