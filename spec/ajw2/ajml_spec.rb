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
      end

      shared_examples "call #parse_*" do |method|
        it "should call \##{method}" do
          Ajw2::Ajml.any_instance.should_receive(method).with(path)
          ajml = Ajw2::Ajml.new
          ajml.parse(path)
        end
      end

      shared_examples "call #validate" do
        it "should call #validate" do
          Ajw2::Ajml.any_instance.should_receive(:validate)
          ajml = Ajw2::Ajml.new
          ajml.parse(path)
        end
      end

      context "with .ajml" do
        include_context "with valid file" do
          let(:path) { @ajml_path }
        end

        # it_behaves_like "call #validate" do
        #   let(:path) { @ajml_path }
        # end

        # it_behaves_like "call #parse_*", :parse_xml do
        #   let(:path) { @ajml_path }
        # end
      end

      context "with .xml" do
        include_context "with valid file" do
          let(:path) { @xml_path }
        end

        # it_behaves_like "call #validate" do
        #   let(:path) { @xml_path }
        # end

        # it_behaves_like "call #parse_*", :parse_xml do
        #   let(:path) { @xml_path }
        # end
      end

      context "with .json" do
        include_context "with valid file" do
          let(:path) { @json_path }
        end

        # it_behaves_like "call #validate" do
        #   let(:path) { @json_path }
        # end

        # it_behaves_like "call #parse_*", :parse_json do
        #   let(:path) { @json_path }
        # end
      end

      context "with .yaml" do
        include_context "with valid file" do
          let(:path) { @yaml_path }
        end

        # it_behaves_like "call #validate" do
        #   let(:path) { @yaml_path }
        # end

        # it_behaves_like "call #parse_*", :parse_yaml do
        #   let(:path) { @yaml_path }
        # end
      end

      context "with .yml" do
        include_context "with valid file" do
          let(:path) { @yml_path }
        end

        # it_behaves_like "call #validate" do
        #   let(:path) { @yml_path }
        # end

        # it_behaves_like "call #parse_*", :parse_yaml do
        #   let(:path) { @yml_path }
        # end
      end

      context "with invalid file" do
        pending "should raise Exception" do
          lambda {
            ajml = Ajw2::Ajml.new
            ajml.parse(@invalid_ajml_path)
          }.should raise_error
        end
      end

      context "with invalid file extension" do
        pending "should raise Exception" do
          lambda {
            ajml = Ajw2::Ajml.new
            ajml.parse(@invalid_ext_path)
          }.should raise_error
        end
      end

      context "with file is nil" do
        it "should raise Exception" do
          lambda {
            ajml = Ajw2::Ajml.new
            ajml.parse(nil)
          }.should raise_error
        end
      end

      context "with file which does not exist" do
        it "should raise Exception" do
          lambda {
            ajml = Ajw2::Ajml.new
            ajml.parse(@invalid_path + "hogehoge")
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

    shared_examples "lack of element" do |element, msg|
      before(:all) do
        ajml = Ajw2::Ajml.new
        hash = AJML_HASH_APPLICATION.reject { |key, _| key == element }
        @result, @msg = ajml.validate(hash)
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

      it "should return with specified message" do
        @msg.first.should eql msg
      end
    end

    describe "#validate" do
      before(:all) { @ajml = Ajw2::Ajml.new }

      context "with valid Ajml" do
        before { @result, @msg = @ajml.validate(AJML_HASH_APPLICATION) }

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

      context "with invalid Ajml" do
        context "that doesn't contain name" do
          it_behaves_like "lack of element", "name", "name is missing"
        end

        context "that doesn't contain interfaces section" do
          it_behaves_like "lack of element", "interfaces", "interfaces is missing"
        end

        context "that doesn't contain databases section" do
          it_behaves_like "lack of element", "databases", "databases is missing"
        end

        context "that doesn't contain events section" do
          it_behaves_like "lack of element", "events", "events is missing"
        end
      end
    end
  end
end
