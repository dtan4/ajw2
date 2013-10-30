require "spec_helper"

module Ajw2::Template
  describe HTML do
    let(:html) { Ajw2::Template::HTML.new }

    describe "#generate_html" do

    end

    describe "#make_header" do
      context "with title" do
        subject { html.make_header(title: "hoge") }
        it { should be_instance_of String }
        it { should == <<-EOS
<head>
<meta charset="utf-8">
<title>hoge</title>
</head>
EOS
        }
      end

      context "with no title" do
        it "should raise Exception" do
          lambda { html.make_header }.should raise_error
        end
      end
    end

    describe "#plain_text" do
      context "with plain text entirely" do
        subject { html.plain_text("hogehoge") }
        it { should be_instance_of String }
        it { should == "hogehoge" }
      end

      context "with special characters" do
        subject { html.plain_text('<script>alert("hoge");</script>') }
        it { should be_instance_of String }
        it { should == '&lt;script&gt;alert(&quot;hoge&quot;);&lt;/script&gt;'}
      end
    end

    describe "#escape_options" do
      context "with plain characters only" do
        let(:result) { html.escape_options(type: "text", id: "hoge") }

        it "should be a Hash object" do
          result.should be_instance_of Hash
        end

        it "should return escaped options" do
          result.should == {type: "text", id: "hoge"}
        end
      end

      context "with special characters" do
        let(:result) {
          html.escape_options(type: "text", value: '"> <script>alert(1)</script>')
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
