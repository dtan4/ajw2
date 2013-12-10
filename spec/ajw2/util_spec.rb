require "spec_helper"

describe Ajw2::Util do
  class DummyClass
  end

  before(:all) do
    @dummy = DummyClass.new
    @dummy.extend Ajw2::Util
  end

  describe "#indent" do
    context "with 0" do
      it "should add no indentation" do
        expect(@dummy.indent("hoge", 0)).to eq "hoge"
      end
    end

    context "with positive number" do
      it "should add indentation" do
        expect(@dummy.indent("hoge", 2)).to eq "    hoge"
      end
    end

    context "with negative number" do
      it "should raise Exception" do
        expect { @dummy.indent("hoge", -2) }.to raise_error ArgumentError, "Negative number is given"
      end
    end
  end
end
