require "spec_helper"

module Ajw2
  describe Source do
    before(:all) do
      @json_path = fixture_path("chat.json")
      @yaml_path = fixture_path("chat.yaml")
      @yml_path = fixture_path("chat.yml")
      @invalid_path = fixture_path("chat.txt")
    end

    describe "#parse_file" do
      shared_context "with valid file" do
        before do
          @source = Ajw2::Source.new
          @source.parse_file(path)
        end

        it "should set application" do
          expect(@source.application).to be_an_instance_of Ajw2::Model::Application
        end

        it "should set interface" do
          expect(@source.interface).to be_an_instance_of Ajw2::Model::Interface
        end

        it "should set database" do
          expect(@source.database).to be_an_instance_of Ajw2::Model::Database
        end

        it "should set event" do
          expect(@source.event).to be_an_instance_of Ajw2::Model::Event
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
            source = Ajw2::Source.new
            source.parse_file(@invalid_source_path)
          }.to raise_error
        end
      end

      context "with invalid file extension" do
        it "should raise Exception" do
          expect {
            source = Ajw2::Source.new
            source.parse_file(@invalid_ext_path)
          }.to raise_error
        end
      end

      context "with file is nil" do
        it "should raise Exception" do
          expect {
            source = Ajw2::Source.new
            source.parse_file(nil)
          }.to raise_error
        end
      end

      context "with file which does not exist" do
        it "should raise Exception" do
          expect {
            source = Ajw2::Source.new
            source.parse_file(@invalid_path + "hogehoge")
          }.to raise_error
        end
      end
    end
  end
end
