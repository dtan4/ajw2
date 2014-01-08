require "spec_helper"

module Ajw2::Model
  describe Interface do
    let(:source) {
      {
       type: "slim", pretty: true,
       elements: [
                  {
                   type: "panel", id: "rootPanel",
                   children: [
                              { type: "label", value: "Chat Application", id: "label0" },
                              { type: "text", id: "userIdTextbox", placeholder: "user name" },
                              { type: "button", value: "Selection", id: "selectButton" },
                              { type: "button", value: "hidden", id: "hiddenButton", hidden: true }
                             ]
                  }
                 ]
      }
    }

    let(:dirty_source) {
      {
       type: "slim", pretty: true,
       elements: [
                  {
                   type: "panel", id: "rootPanel",
                   children: [
                              { type: "label", value: "<script>alert('xss');</script>", id: "label0" },
                              { type: "text", id: "userIdTextbox", placeholder: '<script>alert("xss");</script>' },
                              { type: "button", value: "Selection", id: "selectButton" }
                             ]
                  }
                 ]
      }
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Interface.new(source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should raise ArgumentError" do
          expect { Ajw2::Model::Interface.new("hoge") }.to raise_error ArgumentError,
            "Interface section must be a Hash"
        end
      end
    end

    describe "#render" do
      context "with clean source" do
        subject { Ajw2::Model::Interface.new(source).render }
        it { should be_an_instance_of String }

        it "should return Slim template" do
          expect(subject).to eq(<<-EOS)
#rootPanel
  label#label0
    | Chat Application
  input#userIdTextbox type="text" placeholder="user name"
  button#selectButton
    | Selection
  button#hiddenButton style="display: none"
    | hidden
EOS
        end
      end

      context "with dirty source (include XSS)" do
        subject { Ajw2::Model::Interface.new(dirty_source).render }
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
        it "should raise Exception" do
          expect {
            puts Ajw2::Model::Interface.new({}).render
          }.to raise_error RuntimeError, "/interface/elements is not found"
        end
      end
    end
  end
end
