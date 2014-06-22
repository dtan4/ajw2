require "spec_helper"

module Ajw2
  describe Source do
    let(:json_path) do
      fixture_path("chat.json")
    end

    let(:yaml_path) do
      fixture_path("chat.yaml")
    end

    let(:yml_path) do
      fixture_path("chat.yml")
    end

    let(:invalid_path) do
      fixture_path("chat.txt")
    end

    let(:source) do
      Ajw2::Source.new
    end

    describe "#parse_file" do
      let(:parse_file) do
        source.parse_file(path)
      end

      shared_examples_for "parse successfully" do
        before do
          parse_file
        end

        it "should set application" do
          expect(source.application).to be_an_instance_of Ajw2::Model::Application
        end

        it "should set interface" do
          expect(source.interface).to be_an_instance_of Ajw2::Model::Interface
        end

        it "should set database" do
          expect(source.database).to be_an_instance_of Ajw2::Model::Database
        end

        it "should set event" do
          expect(source.event).to be_an_instance_of Ajw2::Model::Event
        end
      end

      shared_examples_for "fail to parse" do
        it "should raise Exception" do
          expect do
            parse_file
          end.to raise_error
        end
      end

      context "with .json" do
        let(:path) do
          json_path
        end

        it_behaves_like "parse successfully"
      end

      context "with .yaml" do
        let(:path) do
          yaml_path
        end

        it_behaves_like "parse successfully"
      end

      context "with .yml" do
        let(:path) do
          yml_path
        end

        it_behaves_like "parse successfully"
      end

      context "with invalid file" do
        let(:path) do
          invalid_source_path
        end

        it_behaves_like "fail to parse"
      end

      context "with invalid file extension" do
        let(:path) do
          invalid_ext_path
        end

        it_behaves_like "fail to parse"
      end

      context "with file is nil" do
        let(:path) do
          nil
        end

        it_behaves_like "fail to parse"
      end

      context "with file which does not exist" do
        let(:path) do
          invalid_path + "hogehoge"
        end

        it_behaves_like "fail to parse"
      end
    end
  end
end
