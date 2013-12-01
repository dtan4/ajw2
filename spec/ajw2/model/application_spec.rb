require "spec_helper"

module Ajw2::Model
  describe Application do
    let(:source) {
      {
       name: "sample"
      }
    }

    describe "#initialize" do
      context "with String" do
        subject { Ajw2::Model::Application.new(source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should raise ArgumentError" do
          expect { Ajw2::Model::Application.new("a") }.to raise_error ArgumentError,
            "Application section must be a Hash"
        end
      end
    end

    describe "#render_header" do
      before { @header = Ajw2::Model::Application.new(source).render_header }

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
