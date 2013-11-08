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
      shared_context "with valid file" do |method|
        before(:all) do
          @ajml = Ajw2::Ajml.new
          @ajml.parse(path)
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

        # it "should call #{method}" do
        #   Ajw2::Ajml.any_instance.should_receive(method).with(path)
        #   @ajml.parse(path)
        # end
      end

      context "with .ajml" do
        include_context "with valid file", :parse_xml do
          let(:path) { @ajml_path }
        end
      end

      context "with .xml" do
        include_context "with valid file", :parse_xml do
          let(:path) { @xml_path }
          before(:all) { @path = @xml_path }
        end
      end

      context "with .json" do
        include_context "with valid file", :parse_json do
          let(:path) { @json_path }
          before(:all) { @path = @json_path }
        end
      end

      context "with .yaml" do
        include_context "with valid file", :parse_yaml do
          let(:path) { @yaml_path }
          before(:all) { @path = @yaml_path }
        end
      end

      context "with .yml" do
        include_context "with valid file", :parse_yaml do
          let(:path) { @yml_path }
        end
      end

      context "with invalid file extension" do
        it "should raise Exception" do
          lambda {
            @ajml.parse(@invalid_path)
          }.should raise_error
        end
      end

      context "with file is nil" do
        it "should raise Exception" do
          lambda {
            @ajml.parse(nil)
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

    shared_context "with valid data" do |method|
      let(:ajml) { Ajw2::Ajml.new }

      it "should return Hash" do
        ajml.send(method, path).should be_instance_of Hash
      end

      it "should call #extract_application_section" do
        Ajw2::Ajml.any_instance.should_receive(:extract_application_section)
        ajml.send(method, path)
      end
    end

    shared_context "with invalid data" do |method|
      let(:ajml) { Ajw2::Ajml.new }

      pending "should raise Exception" do
        lambda {
          ajml.send(method, path)
        }.should raise_error
      end
    end

    describe "#parse_xml" do
      include_context "with valid data", :parse_xml do
        let(:path) { @ajml_path }
      end

      include_context "with invalid data", :parse_xml do
        let(:path) { @ajml_path }
      end
    end

    describe "#parse_json" do
      include_context "with valid data", :parse_json do
        let(:path) { @json_path }
      end

      include_context "with invalid data", :parse_json do
        let(:path) { @json_path }
      end
    end

    describe "#parse_yaml" do
      include_context "with valid data", :parse_yaml do
        let(:path) { @yaml_path }
      end

      include_context "with invalid data", :parse_yaml do
        let(:path) { @json_path }
      end
    end

    describe "#extract_application_section" do
      before(:each) { @ajml = Ajw2::Ajml.new }

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

    shared_context "with valid object" do |method|
      before do
        ajml = Ajw2::Ajml.new
        @result, @msg = ajml.send(method, obj)
      end

      it "should return true" do
        @result.should be_true
      end

      it "should return Array message" do
        @msg.should be_instance_of Array
      end

      it "should return empty Array" do
        @msg.should be_empty
      end
    end

    shared_context "with invalid object" do |method, count, msg|
      before do
        ajml = Ajw2::Ajml.new
        @result, @msg = ajml.send(method, obj)
      end

      pending do
        it "should return false" do
          @result.should be_false
        end

        it "should return Array message" do
          @msg.should be_instance_of Array
        end

        it "should return specified numbers of message" do
          @msg.should have(count).items
        end

        it "should return with specified message" do
          @msg.should eql expected_msg
        end
      end
    end

    describe "#validate" do
      before(:all) { @ajml = Ajw2::Ajml.new }

      context "with valid Ajml" do
        include_context "with valid object", :validate do
          let(:obj) { AJML_HASH_APPLICATION }
        end

        it "should call #validate_name" do
          Ajw2::Ajml.any_instance.should_receive(:validate_name)
            .with(AJML_HASH_APPLICATION["name"])
          @ajml.validate(AJML_HASH_APPLICATION)
        end

        it "should call #validate_interfaces" do
          Ajw2::Ajml.any_instance.should_receive(:validate_interfaces)
            .with(AJML_HASH_APPLICATION["interfaces"])
          @ajml.validate(AJML_HASH_APPLICATION)
        end

        it "should call #validate_databases" do
          Ajw2::Ajml.any_instance.should_receive(:validate_databases)
            .with(AJML_HASH_APPLICATION["databases"])
          @ajml.validate(AJML_HASH_APPLICATION)
        end

        it "should call #validate_events" do
          Ajw2::Ajml.any_instance.should_receive(:validate_events)
            .with(AJML_HASH_APPLICATION["events"])
          @ajml.validate(AJML_HASH_APPLICATION)
        end
      end

      pending "with invalid Ajml" do
      # context "with invalid Ajml" do
        include_context "with invalid object"

        context "that doesn't contain interfaces section" do
          it "should not call #validate_interfaces" do
            Ajw2::Ajml.any_instance.should_not_receive(:validate_interfaces)
            @ajml.validate(AJML_HASH_APPLICATION)
          end
        end

        context "that doesn't contain databases section" do
          it "should not call #validate_databases" do
            Ajw2::Ajml.any_instance.should_not_receive(:validate_databases)
            @ajml.validate(AJML_HASH_APPLICATION)
          end
        end

        context "that doesn't contain events section" do
          it "should not call #validate_eventes" do
            Ajw2::Ajml.any_instance.should_not_receive(:validate_events)
            @ajml.validate(AJML_HASH_APPLICATION)
          end
        end
      end
    end

    shared_context "with nil argument" do |method, msg|
      before do
        ajml = Ajw2::Ajml.new
        @result, @msg = ajml.send(method, nil)
      end

      it "should return false" do
        @result.should be_false
      end

      it "should return Array message" do
        @msg.should be_instance_of Array
      end

      it "should return 1 message" do
        @msg.should have(1).item
      end

      it "should return the specified message" do
        @msg.should include(msg)
      end
    end

    describe "#validate_name" do
      context "with non-nil argument" do
        include_context "with valid object", :validate_name do
          let(:obj) { AJML_HASH_APPLICATION["name"] }
        end
      end

      context "with non-nil argument" do
        include_context "with invalid object", :validate_name do
          let(:obj) { AJML_HASH_APPLICATION["name"] }
        end
      end

      include_context "with nil argument", :validate_name, "name is missing"
    end

    describe "#validate_interfaces" do
      context "with non-nil argument" do
        include_context "with valid object", :validate_interfaces do
          let(:obj) { AJML_HASH_APPLICATION["interfaces"] }
        end

        include_context "with invalid object", :validate_interfaces do
          let(:obj) { AJML_HASH_APPLICATION["interfaces"] }
        end
      end

      include_context "with nil argument", :validate_interfaces, "interfaces is missing"
    end

    describe "#validate_databases" do
      context "with non-nil argument" do
        include_context "with valid object", :validate_databases do
          let(:obj) { AJML_HASH_APPLICATION["databases"] }
        end

        include_context "with invalid object", :validate_databases do
          let(:obj) { AJML_HASH_APPLICATION["databases"] }
        end
      end

      include_context "with nil argument", :validate_databases, "databases is missing"
    end

    describe "#validate_events" do
      context "with non-nil argument" do
        include_context "with valid object", :validate_events do
          let(:obj) { AJML_HASH_APPLICATION["events"] }
        end

        include_context "with invalid object", :validate_events do
          let(:obj) { AJML_HASH_APPLICATION["events"] }
        end
      end

      include_context "with nil argument", :validate_events, "events is missing"
    end
  end
end
