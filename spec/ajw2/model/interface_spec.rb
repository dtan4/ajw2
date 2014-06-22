require "spec_helper"

module Ajw2::Model
  describe Interface do
    let(:source) do
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
    end

    let(:dirty_source) do
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
    end

    let(:invalid_source) do
      {}
    end

    let(:interface) do
      described_class.new(source)
    end

    describe "#initialize" do
      let(:interface) do
        described_class.new(arg)
      end

      context "with Hash" do
        let(:arg) do
          source
        end

        it "should an instance of Interface" do
          expect(interface).to be_a described_class
        end
      end

      context "with non-Hash" do
        let(:arg) do
          "hoge"
        end

        it "should raise ArgumentError" do
          expect do
            interface
          end.to raise_error ArgumentError, "Interface section must be a Hash"
        end
      end
    end

    describe "#render" do
      let(:render) do
        interface.render
      end

      context "with clean source" do
        it "should return Slim template" do
          expect(render).to eq(<<-EOS)
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
        let(:source) do
          dirty_source
        end

        it "should return escaped Slim template" do
          expect(render).to eq(<<-EOS)
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
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render
          end.to raise_error RuntimeError, "/interface/elements is not found"
        end
      end
    end
  end
end
