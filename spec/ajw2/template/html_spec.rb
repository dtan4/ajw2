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
  end
end
