require "spec_helper"

module Ajw2::Model
  describe Interfaces do
    let(:source) {
      {
       type: "slim",
       pretty: true,
       elements:
       [
        {
         type: "panel",
         _isDisplay: true,
         height: 500,
         id: "rootPanel",
         left: 72,
         top: 2,
         width: 700,
         children: [
                    {
                     type: "label",
                     value: "Chat Application",
                     id: "label0",
                     left: 27,
                     top: 22
                    },
                    {
                     type: "text",
                     id: "userIdTextbox",
                     placeholder: "user name",
                     left: 132,
                     top: 29,
                     width: 100
                    },
                    {
                     type: "button",
                     value: "Selection",
                     id: "selectButton",
                     left: 369,
                     top: 50
                    }
                   ]
        }
       ]
      }
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Interfaces.new(source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should raise Exception" do
          expect { Ajw2::Model::Interfaces.new("hoge") }.to raise_error
        end
      end
    end

    describe "#render" do
      context "with clean source" do
        subject { Ajw2::Model::Interfaces.new(source).render }
        it { should be_an_instance_of String }

        it "should return Slim template" do
          expect(subject).to eq(<<-EOS)
#rootPanel
  label#label0
    | Chat Application
  input#userIdTextbox type="text" placeholder="user name"
  button#selectButton
    | Selection
EOS
        end
      end

      context "with dirty source (include XSS)" do
        before do
          @dirty_source = source
          @dirty_source[:elements][0][:children][0][:value] =
            "<script>alert('xss');</script>"
          @dirty_source[:elements][0][:children][1][:placeholder] =
            '<script>alert("xss");</script>'
        end

        subject { Ajw2::Model::Interfaces.new(source).render }
        it { should be_an_instance_of String }

        it "should return escaped Slim template" do
          expect(subject).to eq(<<-EOS)
#rootPanel
  label#label0
    | &lt;script&gt;alert(&#39;xss&#39;);&lt;/script&gt;
  input#userIdTextbox type="text" placeholder="&lt;script&gt;alert(&quot;xss&quot;);&lt;/script&gt;"
  button#selectButton
    | Selection
EOS
        end
      end

      context "with invalid source" do
        @invalid_sources = [
                            {
                             elements: [{ type: "panel" }]
                            },
                            {
                             elements: [{ id: "hoge" }]
                            }
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
