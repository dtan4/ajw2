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
