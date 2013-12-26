require "spec_helper"

module Ajw2
  describe Description do
    before(:all) do
      @description_path = fixture_path("chat.description")
      @xml_path = fixture_path("chat.xml")
      @json_path = fixture_path("chat.json")
      @yaml_path = fixture_path("chat.yaml")
      @yml_path = fixture_path("chat.yml")
      @invalid_path = fixture_path("chat.txt")
    end

    describe "#parse" do
      shared_context "with valid file" do
        before do
          @description = Ajw2::Description.new
          @description.parse(path)
        end

        it "should set application" do
          expect(@description.application).to be_an_instance_of Ajw2::Model::Application
        end

        it "should set interfaces" do
          expect(@description.interfaces).to be_an_instance_of Ajw2::Model::Interfaces
        end

        it "should set databases" do
          expect(@description.databases).to be_an_instance_of Ajw2::Model::Databases
        end

        it "should set events" do
          expect(@description.events).to be_an_instance_of Ajw2::Model::Events
        end
      end

      context "with .json" do
        include_context "with valid file" do
          let(:path) { @json_path }
        end
      end

      context "with .yaml" do
        include_context "with valid file" do
          let(:path) { @yaml_path }
        end
      end

      context "with .yml" do
        include_context "with valid file" do
          let(:path) { @yml_path }
        end
      end

      context "with invalid file" do
        it "should raise Exception" do
          expect {
            description = Ajw2::Description.new
            description.parse(@invalid_description_path)
          }.to raise_error
        end
      end

      context "with invalid file extension" do
        it "should raise Exception" do
          expect {
            description = Ajw2::Description.new
            description.parse(@invalid_ext_path)
          }.to raise_error
        end
      end

      context "with file is nil" do
        it "should raise Exception" do
          expect {
            description = Ajw2::Description.new
            description.parse(nil)
          }.to raise_error
        end
      end

      context "with file which does not exist" do
        it "should raise Exception" do
          expect {
            description = Ajw2::Description.new
            description.parse(@invalid_path + "hogehoge")
          }.to raise_error
        end
      end
    end
  end
end
