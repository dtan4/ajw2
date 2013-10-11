require "spec_helper"

module AjwebGenerator
  describe Template do
    describe "#initialize" do
      it "should call #set_param" do
        AjwebGenerator::Template.any_instance.should_receive(:set_param)
        AjwebGenerator::Template.new
      end
    end

    describe "#set_param" do
      pending
    end

    describe "#apply" do
      pending
    end
  end
end
