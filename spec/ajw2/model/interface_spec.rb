require "spec_helper"

module Ajw2::Model
  describe Interface do
    let(:source) {
      {
       elements: [
                  {
                   type: "panel", id: "rootPanel", class: "",
                   children: [
                              { type: "label", value: "Chat Application", id: "label0", class: "" },
                              { type: "text", id: "userIdTextbox", placeholder: "user name", class: "form-control" },
                              { type: "button", value: "Selection", id: "selectButton", class: "form-control btn" },
                              { type: "button", value: "hidden", id: "hiddenButton", class: "", hidden: true }
                             ]
                  }
                 ]
      }
    }

    let(:dirty_source) {
      {
       elements: [
                  {
                   type: "panel", id: "rootPanel", class: "",
                   children: [
                              { type: "label", value: "<script>alert('xss');</script>", id: "label0", class: "" },
                              { type: "text", id: "userIdTextbox", class: "", placeholder: '<script>alert("xss");</script>' },
                              { type: "button", value: "Selection", id: "selectButton", class: "" }
                             ]
                  }
                 ]
      }
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Interface.new(source) }

        describe '#source' do
          subject { super().source }
          it { is_expected.to be_instance_of Hash }
        end
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
        it { is_expected.to be_an_instance_of String }

        it "should return Slim template" do
          expect(subject).to eq(<<-EOS)
#rootPanel
  label#label0
    | Chat Application
  input.form-control#userIdTextbox type="text" placeholder="user name"
  button.form-control.btn#selectButton
    | Selection
  button#hiddenButton style="display: none"
    | hidden
EOS
        end
      end

      context "with dirty source (include XSS)" do
        subject { Ajw2::Model::Interface.new(dirty_source).render }
        it { is_expected.to be_an_instance_of String }

        it "should return escaped Slim template" do
          expect(subject).to eq(<<-EOS)
#rootPanel
  label#label0
    | &lt;script&gt;alert(&#39;xss&#39;);&lt;/script&gt;
  input#userIdTextbox type="text" placeholder="<script>alert("xss");</script>"
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
