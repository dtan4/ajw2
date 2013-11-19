require "spec_helper"

module Ajw2::Model
  describe Application do
    describe "#initialize" do
      subject { Ajw2::Model::Application.new("sample") }
      its(:name) { should be_instance_of String }
      its(:name) { should == "sample" }
    end

    describe "#render_header" do
      before { @header = Ajw2::Model::Application.new("sample").render_header }

      it "should return String" do
        expect(@header).to be_an_instance_of String
      end

      it "should return Slim template" do
        expect(@header).to eq(<<-EOS)
meta charset="utf-8"
title sample
EOS
      end
    end
  end
end
