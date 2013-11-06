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

      load File.expand_path("../fixtures/ajml_hash.rb", __dir__)
      load File.expand_path("../fixtures/ajml_hash_application.rb", __dir__)
      puts @ajml_path
    end

    describe "#parse" do
      shared_examples_for "parse_ajml_file" do
        let(:result) { Ajw2::Ajml.parse(path) }

        it "should return Hash" do
          result.should be_instance_of Hash
        end

        it "should be equal to AJML_HASH_APPLICATION" do
          result.should eql AJML_HASH_APPLICATION
        end
      end

      context "with .ajml" do
        let(:path) { @ajml_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_xml" do
          Ajw2::Ajml.should_receive(:parse_xml)
          Ajw2::Ajml.parse(@ajml_path)
        end
      end

      context "with .xml" do
        let(:path) { @xml_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_xml" do
          Ajw2::Ajml.should_receive(:parse_xml)
          Ajw2::Ajml.parse(@xml_path)
        end
      end

      context "with .json" do
        let(:path) { @json_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_json" do
          Ajw2::Ajml.should_receive(:parse_json)
          Ajw2::Ajml.parse(@json_path)
        end
      end

      context "with .yaml" do
        let(:path) { @yaml_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_yaml" do
          Ajw2::Ajml.should_receive(:parse_yaml)
          Ajw2::Ajml.parse(@yaml_path)
        end
      end

      context "with .yml" do
        let(:path) { @yml_path }
        it_behaves_like "parse_ajml_file"

        it "should call #parse_yaml" do
          Ajw2::Ajml.should_receive(:parse_yaml)
          Ajw2::Ajml.parse(@yml_path)
        end
      end

      context "with invalid file extension" do
        it "should raise Exception" do
          lambda {
            Ajw2::Ajml.parse(@invalid_path)
          }.should raise_error
        end
      end

      context "with file which does not exist" do
        it "should raise Exception" do
          lambda {
            Ajw2::Ajml.parse(@invalid_path + "hogehoge")
          }.should raise_error
        end
      end
    end

    describe "#parse_xml" do
      context "with valid xml" do
        it "should return Hash" do
          Ajw2::Ajml.parse_xml(@ajml_path).should be_instance_of Hash
        end

        it "should call #extract_application_section" do
          Ajw2::Ajml.should_receive(:extract_application_section)
          Ajw2::Ajml.parse_xml(@ajml_path)
        end
      end

      context "with invalid xml" do
        it "should raise Exception"
      end
    end

    describe "#parse_json" do
      context "with valid json" do
        it "should return Hash" do
          Ajw2::Ajml.parse_json(@json_path).should be_instance_of Hash
        end

        it "should call #extract_application_section" do
          Ajw2::Ajml.should_receive(:extract_application_section)
          Ajw2::Ajml.parse_json(@json_path)
        end
      end

      context "with invalid json" do
        it "should raise Exception"
      end
    end

    describe "#parse_yaml" do
      context "with valid yaml" do
        it "should return Hash" do
          Ajw2::Ajml.parse_yaml(@yaml_path).should be_instance_of Hash
        end

        it "should call #extract_application_section" do
          Ajw2::Ajml.should_receive(:extract_application_section)
          Ajw2::Ajml.parse_yaml(@yaml_path)
        end
      end

      context "with invalid json" do
        it "should raise Exception"
      end
    end

    describe "#extract_application_section" do
      context "with ajml that contains application section" do
        subject { Ajw2::Ajml.extract_application_section(AJML_HASH) }
        it { should eql AJML_HASH_APPLICATION }
      end

      context "with ajml that doesn't contain application section" do
        subject { Ajw2::Ajml.extract_application_section(AJML_HASH_APPLICATION) }
        it { should eql AJML_HASH_APPLICATION }
      end
    end

    describe "#validate" do
      pending do
      let(:invalid_ajml) { load File.expand_path("../fixtures/result_invalid.rb", __dir__) }

      context "with valid Ajml" do
        subject { Ajw2::Ajml.validate(AJML_HASH) }
        it { should be_true }
      end

      context "with invalid Ajml" do
        context "which name is missing" do
          subject { Ajw2::Ajml.validate(invalid_ajml) }
          it { should be_true }
        end

        context "which interfaces is missing" do
          subject { Ajw2::Ajml.validate(ajml) }
          it { should be_true }
        end

        context "which databases is missing" do
          subject { Ajw2::Ajml.validate(ajml) }
          it { should be_true }
        end

        context "which events is missing" do
          subject { Ajw2::Ajml.validate(ajml) }
          it { should be_true }
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
