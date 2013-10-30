require "spec_helper"

module Ajw2::Template
  describe Element do
    let(:element) { Ajw2::Template::Element.new }

    describe "#input" do
      context "with valid input type" do
        # it "should call #escape_options" do
        #   element.should_receive(:escape_options).with(type: "text")
        #   element.input(type: "text")
        # end

        shared_examples_for "valid_type" do |options, expect|
          subject { element.input(options) }
          it { should be_instance_of String }
          it { should == expect }
        end

        context "with type only" do
          it_behaves_like "valid_type", {type: "text"}, '<input type="text">'
        end

        context "with type and id" do
          it_behaves_like "valid_type", {type: "text", id: "hoge"}, '<input type="text" id="hoge">'
        end

        context "with type, id and value" do
          it_behaves_like "valid_type", {type: "text", id: "hoge", value: "fuga"},
          '<input type="text" id="hoge" value="fuga">'
        end

        context "with type and value" do
          it_behaves_like "valid_type", {type: "text", value: "fuga"},
          '<input type="text" value="fuga">'
        end

        context "with special characters" do
          subject { element.input(type: "text", value: '"> <script>alert(1)</script>') }
          it { should be_instance_of String }
          it { should ==
            '<input type="text" value="&quot;&gt; &lt;script&gt;alert(1)&lt;/script&gt;">' }
        end
      end

      context "with invalid input type" do
        it "should raise Exception" do
          lambda {
            element.input(type: "INVALID_TYPE")
          }.should raise_error Exception
        end
      end
    end

    describe "#escape_options" do
      context "with plain characters only" do
        let(:result) { element.escape_options(type: "text", id: "hoge") }

        it "should be a Hash object" do
          result.should be_instance_of Hash
        end

        it "should return escaped options" do
          result.should == {type: "text", id: "hoge"}
        end
      end

      context "with special characters" do
        let(:result) {
          element.escape_options(type: "text", value: '"> <script>alert(1)</script>')
        }

        it "should be a Hash object" do
          result.should be_instance_of Hash
        end

        it "should return escaped options" do
          result.should ==
            {type: "text", value: "&quot;&gt; &lt;script&gt;alert(1)&lt;/script&gt;"}
        end
      end
    end
  end
end
