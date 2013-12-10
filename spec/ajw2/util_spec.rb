# -*- coding: utf-8 -*-
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

  describe "#valid_value?" do
    context "with valid Hash contains only ascii-char" do
      it "should return true" do
        expect(@dummy.valid_hash?({ hoge: "fuga", foo: "bar" })).to be_true
      end
    end

    context "with valid Hash contains breakline" do
      it "should return true" do
        expect(@dummy.valid_hash?({ hoge: "fuga\npiyo", foo: "bar" })).to be_true
      end
    end

    context "with valid Hash contains Unicode char" do
      it "should return true" do
        expect(@dummy.valid_hash?({ hoge: "ふが", foo: "ばー" })).to be_true
      end
    end

    context "with valid deep Hash" do
      it "should return true" do
        expect(@dummy.valid_hash?({ hoge: "fuga", foo: { bar: "baz" } })).to be_true
      end
    end

    context "with invalid hash" do
      it "should return false" do
        expect(@dummy.valid_hash?({ hoge: "fu'ga", foo: "bar" })).to be_false
      end
    end

    context "with invalid deep hash" do
      it "should return false" do
        expect(@dummy.valid_hash?({ hoge: "fuga", foo: { bar: "ba'z" } })).to be_false
      end
    end

    context "with regexp" do
      it "should validate with given regexp" do
        expect(@dummy.valid_hash?({ hoge: "ふが", foo: "ばー" }, /^[a-zA-Z0-9]+$/)).to be_false
      end
    end

    context "with non-Hash" do
      it "should raise Exception" do
        expect { @dummy.valid_hash?("hoge") }.to raise_error ArgumentError, "Non-Hash argument is given"
      end
    end
  end
end
