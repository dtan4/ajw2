require "spec_helper"

module Ajw2
  describe Ajml do
    before(:all) do
      @ajml_path = File.expand_path("../fixtures/chat.ajml", __dir__)
      @xml_path = File.expand_path("../fixtures/chat.xml", __dir__)
      @json_path = File.expand_path("../fixtures/chat.json", __dir__)
      @yaml_path = File.expand_path("../fixtures/chat.yaml", __dir__)
      @yml_path = File.expand_path("../fixtures/chat.yml", __dir__)
      @invalid_path = File.expand_path("../fixtures/chat.txt", __dir__)

      # load Hash fixtures
      load File.expand_path("../fixtures/ajml_sections.rb", __dir__)
    end

    describe "#initialize" do
      subject { Ajw2::Ajml.new}
      it { should respond_to(:name) }
      it { should respond_to(:interfaces) }
      it { should respond_to(:databases) }
      it { should respond_to(:events) }
      its(:name) { should be_instance_of String }
      its(:name) { should == "" }
      its(:interfaces) { should be_instance_of Hash }
      its(:interfaces) { should be_empty }
      its(:databases) { should be_instance_of Hash }
      its(:databases) { should be_empty }
      its(:events) { should be_instance_of Hash }
      its(:events) { should be_empty }
    end

    describe "#parse" do
      shared_context "with valid file" do
        before do
          @ajml = Ajw2::Ajml.new
          @ajml.parse(path)
        end

        it "should set name" do
          expect(@ajml.name).to eq "chat"
        end

        it "should set interfaces" do
          expect(@ajml.interfaces).to eql FIXTURE_INTERFACES
        end

        it "should set databases" do
          expect(@ajml.databases).to eql FIXTURE_DATABASES
        end

        it "should set events" do
          expect(@ajml.events).to eql FIXTURE_EVENTS
        end
      end

      context "with .ajml" do
        include_context "with valid file" do
          let(:path) { @ajml_path }
        end
      end

      context "with .xml" do
        include_context "with valid file" do
          let(:path) { @xml_path }
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
            ajml = Ajw2::Ajml.new
            ajml.parse(@invalid_ajml_path)
          }.to raise_error
        end
      end

      context "with invalid file extension" do
        it "should raise Exception" do
          expect {
            ajml = Ajw2::Ajml.new
            ajml.parse(@invalid_ext_path)
          }.to raise_error
        end
      end

      context "with file is nil" do
        it "should raise Exception" do
          expect {
            ajml = Ajw2::Ajml.new
            ajml.parse(nil)
          }.to raise_error
        end
      end

      context "with file which does not exist" do
        it "should raise Exception" do
          expect {
            ajml = Ajw2::Ajml.new
            ajml.parse(@invalid_path + "hogehoge")
          }.to raise_error
        end
      end
    end
  end
end
