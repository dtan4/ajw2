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
      load File.expand_path("../fixtures/ajml_classic.rb", __dir__)
      load File.expand_path("../fixtures/ajml_sections.rb", __dir__)
      load File.expand_path("../fixtures/ajml.rb", __dir__)
      puts @ajml_path
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
      shared_examples_for "parse_ajml_file" do
        before(:all) do
          @ajml = Ajw2::Ajml.new
          @result = @ajml.parse(path)
        end

        it "should return true" do
          @result.should be_true
        end

        it "should set name" do
          @ajml.name.should == "chat"
        end

        it "should set interfaces" do
          @ajml.interfaces.should eql FIXTURE_INTERFACES
        end

        it "should set databases" do
          @ajml.databases.should eql FIXTURE_DATABASES
        end

        it "should set events" do
          @ajml.events.should eql FIXTURE_EVENTS
        end
      end

      context "with .ajml" do
        let(:path) { @ajml_path }
        it_behaves_like "parse_ajml_file"
      end

      context "with .xml" do
        let(:path) { @xml_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_xml"
      end

      context "with .json" do
        let(:path) { @json_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_json"
      end

      context "with .yaml" do
        let(:path) { @yaml_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_yaml"
      end

      context "with .yml" do
        let(:path) { @yml_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_yaml"
      end

      context "with invalid file extension" do
        it "should raise Exception" do
          lambda {
            @ajml.parse(@invalid_path)
          }.should raise_error
        end
      end

      context "with file which does not exist" do
        it "should raise Exception" do
          lambda {
            @ajml.parse(@invalid_path + "hogehoge")
          }.should raise_error
        end
      end
    end

    # describe "#parse_xml" do
    pending "#parse_xml" do
      before(:each) do
        @ajml = Ajw2::Ajml.new
      end

      context "with valid xml" do
        it "should return Hash" do
          @ajml.parse_xml(@ajml_path).should be_instance_of Hash
        end

        it "should call #extract_application_section"
      end

      context "with invalid xml" do
        it "should raise Exception"
      end
    end

    # describe "#parse_json" do
    pending "#parse_json" do
      before(:each) do
        @ajml = Ajw2::Ajml.new
      end

      context "with valid json" do
        it "should return Hash" do
          @ajml.parse_json(@json_path).should be_instance_of Hash
        end

        it "should call #extract_application_section"
      end

      context "with invalid json" do
        it "should raise Exception"
      end
    end

    # describe "#parse_yaml" do
    pending "#parse_yaml" do
      before(:each) do
        @ajml = Ajw2::Ajml.new
      end

      context "with valid yaml" do
        it "should return Hash" do
          @ajml.parse_yaml(@yaml_path).should be_instance_of Hash
        end

        it "should call #extract_application_section"
      end

      context "with invalid json" do
        it "should raise Exception"
      end
    end

    # describe "#extract_application_section" do
    pending "#extract_application_section" do
      before(:each) do
        @ajml = Ajw2::Ajml.new
      end

      context "with ajml that contains application section" do
        it "should extract application section" do
          result = @ajml.extract_application_section(AJML_HASH)
          result.should eql AJML_HASH_APPLICATION
        end
      end

      context "with ajml that doesn't contain application section" do
        it "should return the same to input" do
          result = @ajml.extract_application_section(AJML_HASH_APPLICATION)
          result.should eql AJML_HASH_APPLICATION
        end
      end
    end

    # describe "#validate" do
    pending "#validate" do
      before(:each) do
        @ajml = Ajw2::Ajml.new
      end

      let(:invalid_ajml) { load File.expand_path("../fixtures/result_invalid.rb", __dir__) }

      context "with valid Ajml" do
        let(:result, :msg) { @ajml.validate(AJML_HASH_APPLICATION) }

        it "should return true"do
          @result.should be_true
        end

        it "should return Array message" do
          @msg.should be_instance_of Array
        end

        it "should return no message" do
          @msg.should have(0).items
        end
      end

      context "with invalid Ajml" do
        shared_examples_for "validate_invalid_ajml" do
          before(:all) { @result, @msg = @ajml.validate(ajml) }

          it "should return false" do
            @result.should be_false
          end

          it "should return Array message" do
            @msg.should be_instance_of Array
          end

          it "should return with specified message" do
            @msg.should eql expected_msg
          end
        end
      end
    end

    describe "#validate_interfaces" do

    end

    describe "#validate_databases" do

    end

    describe "#validate_events" do

    end
  end
end
