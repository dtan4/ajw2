# -*- coding: utf-8 -*-
require "spec_helper"

describe Ajw2::Util do
  class DummyClass
    include Ajw2::Util
  end

  let(:dummy) do
    DummyClass.new
  end

  describe "#indent" do
    let(:indent) do
      dummy.indent(text, level)
    end

    let(:text) do
      "hoge"
    end

    context "with 0" do
      let(:level) do
        0
      end

      it "should add no indent" do
        expect(indent).to eq "hoge"
      end
    end

    context "with positive number" do
      let(:level) do
        2
      end

      it "should add indent" do
        expect(indent).to eq "    hoge"
      end
    end

    context "with negative number" do
      let(:level) do
        -2
      end

      it "should raise Exception" do
        expect do
          indent
        end.to raise_error ArgumentError, "Negative number is given"
      end
    end
  end

  describe "#valid_hash?" do
    context "with valid Hash" do
      context "contains only ascii-char" do
        subject { dummy.valid_hash?({ hoge: "fuga", foo: "bar" }) }
        it { is_expected.to be true }
      end

      context "contains breakline" do
        subject { dummy.valid_hash?({ hoge: "fuga\npiyo", foo: "bar" }) }
        it { is_expected.to be true }
      end

      context "contains Unicode char" do
        subject { dummy.valid_hash?({ hoge: "ふが", foo: "ばー" }) }
        it { is_expected.to be true }
      end

      context "contains Array" do
        subject { dummy.valid_hash?({ hoge: "fuga", foo: [{ foo: "bar" }, { baz: "moo" }] }) }
        it { is_expected.to be true }
      end

      context "contains Hash" do
        subject { dummy.valid_hash?({ hoge: "fuga", foo: { bar: "baz" } }) }
        it { is_expected.to be true }
      end
    end

    context "with invalid hash" do
      context "contains only String" do
        subject { dummy.valid_hash?({ hoge: "fu'ga", foo: "bar" }) }
        it { is_expected.to be false }
      end

      context "contains hash" do
        subject { dummy.valid_hash?({ hoge: "fuga", foo: { bar: "ba'z" } }) }
        it { is_expected.to be false }
      end
    end

    context "with regexp" do
      subject { dummy.valid_hash?({ hoge: "ふが", foo: "ばー" }, /^[a-zA-Z0-9]+$/) }
      it { is_expected.to be false }
    end

    context "with non-Hash" do
      it "should raise Exception" do
        expect { dummy.valid_hash?("hoge") }.to raise_error ArgumentError, "Non-Hash argument is given"
      end
    end
  end

  describe "#symbolize_keys" do
    let(:symbolize_keys) do
      dummy.symbolize_keys(hash)
    end

    context "with flat Hash" do
      let(:hash) do
        { "hoge" => "fuga", "foo" => "bar" }
      end

      it "shuold return Hash with symbolized keys" do
        expect(symbolize_keys).to eq({ hoge: "fuga", foo: "bar" })
      end
    end

    context "with deep Hash" do
      let(:hash) do
        { "hoge" => "fuga", "foo" => { "bar" => "baz" } }
      end

      it "should return Hash with symbolized keys" do
        expect(symbolize_keys).to eq({ hoge: "fuga", foo: { bar: "baz" } })
      end
    end
  end
end
