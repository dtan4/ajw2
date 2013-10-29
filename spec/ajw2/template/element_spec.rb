require "spec_helper"

module Ajw2::Template
  describe Element do
    let(:element) { Ajw2::Template::Element.new }

    describe "#input" do
      context "with valid input type" do
        context "with type only" do
          subject { element.input(type: "text") }
          it { should be_instance_of String }
          it { should == '<input type="text">' }
        end

        context "with type and id" do
          subject { element.input(type: "text", id: "hoge") }
          it { should be_instance_of String }
          it { should == '<input type="text" id="hoge">' }
        end

        context "with type, id and value" do
          subject { element.input(type: "text", id: "hoge", value: "fuga") }
          it { should be_instance_of String }
          it { should == '<input type="text" id="hoge" value="fuga">' }
        end

        context "with type and value" do
          subject { element.input(type: "text", value: "fuga") }
          it { should be_instance_of String }
          it { should == '<input type="text" value="fuga">' }
        end

        context "with double quotes" do
          subject { element.input(type: "text", value: '" onclick="alert(1)"') }
          it { should be_instance_of String }
          it { should == '<input type="text" value="&quot; onclick=&quot;alert(1)&quot;">' }
        end

        context "with html tags" do
          subject { element.input(type: "text", value: '"> <script>alert(1)</script>') }
          it { should be_instance_of String }
          it { should == '<input type="text" value="&quot;&gt; &lt;script&gt;alert(1)&lt;/script&gt;">' }
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
  end
end
