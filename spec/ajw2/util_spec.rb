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
      subject { @dummy.indent("hoge", 0) }
      it { is_expected.to be_kind_of String }

      it "should add no indent" do
        expect(subject).to eq "hoge"
      end
    end

    context "with positive number" do
      subject { @dummy.indent("hoge", 2) }
      it { is_expected.to be_kind_of String }

      it "should add indent" do
        expect(subject).to eq "    hoge"
      end
    end

    context "with negative number" do
      it "should raise Exception" do
        expect { @dummy.indent("hoge", -2) }.to raise_error ArgumentError, "Negative number is given"
      end
    end
  end

  describe "#valid_hash?" do
    context "with valid Hash" do
      context "contains only ascii-char" do
        subject { @dummy.valid_hash?({ hoge: "fuga", foo: "bar" }) }
        it { is_expected.to be_truthy }
      end

      context "contains breakline" do
        subject { @dummy.valid_hash?({ hoge: "fuga\npiyo", foo: "bar" }) }
        it { is_expected.to be_truthy }
      end

      context "contains Unicode char" do
        subject { @dummy.valid_hash?({ hoge: "ふが", foo: "ばー" }) }
        it { is_expected.to be_truthy }
      end

      context "contains Array" do
        subject { @dummy.valid_hash?({ hoge: "fuga", foo: [{ foo: "bar" }, { baz: "moo" }] }) }
        it { is_expected.to be_truthy }
      end

      context "contains Hash" do
        subject { @dummy.valid_hash?({ hoge: "fuga", foo: { bar: "baz" } }) }
        it { is_expected.to be_truthy }
      end
    end

    context "with invalid hash" do
      context "contains only String" do
        subject { @dummy.valid_hash?({ hoge: "fu'ga", foo: "bar" }) }
        it { is_expected.to be_falsey }
      end

      context "contains hash" do
        subject { @dummy.valid_hash?({ hoge: "fuga", foo: { bar: "ba'z" } }) }
        it { is_expected.to be_falsey }
      end
    end

    context "with regexp" do
      subject { @dummy.valid_hash?({ hoge: "ふが", foo: "ばー" }, /^[a-zA-Z0-9]+$/) }
      it { is_expected.to be_falsey }
    end

    context "with non-Hash" do
      it "should raise Exception" do
        expect { @dummy.valid_hash?("hoge") }.to raise_error ArgumentError, "Non-Hash argument is given"
      end
    end
  end

  describe "#symbolize_keys" do
    context "with flat Hash" do
      subject { @dummy.symbolize_keys({ "hoge" => "fuga", "foo" => "bar" }) }

      it "shuold return Hash with symbolized keys" do
        expect(subject).to eq({ hoge: "fuga", foo: "bar" })
      end
    end

    context "with deep Hash" do
      subject { @dummy.symbolize_keys({ "hoge" => "fuga", "foo" => { "bar" => "baz" } }) }

      it "should return Hash with symbolized keys" do
        expect(subject).to eq({ hoge: "fuga", foo: { bar: "baz" } })
      end
    end
  end
end
