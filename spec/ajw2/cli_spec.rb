require "spec_helper"
require "fileutils"

module Ajw2
  describe Cli do
    describe "#execute" do
      context "with valid argument" do
        let(:source) do
          fixture_path("chat.json")
        end

        let(:out_dir) do
          "test_cli"
        end

        let(:external_resource_dir) do
          "test_ext_files"
        end

        shared_examples_for "execute successfully" do
          before { Ajw2::Cli.execute(args) }

          it "should create out_dir" do
            expect(Dir.exist?(out_dir)).to be true
          end

          [
           "app.rb",
           "config.ru",
           "Rakefile",
           "Gemfile",
           "views/layout.slim",
           "views/index.slim",
           "config/database.yml",
           "db/migrate/001_create_messages.rb",
           "public/js/jquery.min.js",
           "public/js/app.js"
          ].each do |path|
            it "should create #{path}" do
              expect(File.exist?(File.expand_path(path, out_dir))).to be true
            end
          end

          after { FileUtils.rm_r(out_dir) if Dir.exist? out_dir }
        end

        context "2 arguments" do
          let(:args) do
            "#{source} -o #{out_dir}".split(" ")
          end

          before do
            FileUtils.rm_r(out_dir) if Dir.exist? out_dir
          end

          it_behaves_like "execute successfully"
        end

        context "3 arguments" do
          let(:args) do
            "#{source} -o #{out_dir} -e #{external_resource_dir}".split(" ")
          end

          before do
            FileUtils.rm_r(out_dir) if Dir.exist? out_dir
          end

          it_behaves_like "execute successfully"
        end

        context "long options" do
          let(:args) do
            "#{source} --output #{out_dir} --external #{external_resource_dir}".split(" ")
          end

          before do
            FileUtils.rm_r(out_dir) if Dir.exist? out_dir
          end

          it_behaves_like "execute successfully"
        end
      end

      context "with invalid argument" do
        context "invalid arguments count" do
          let(:args) do
            []
          end

          it "should raise ArgumentError" do
            expect { Ajw2::Cli.execute(args) }.to raise_error ArgumentError
          end
        end

        context "invalid value" do
          let(:source) do
            "hoge"
          end

          let(:out_dir) do
            "fuga"
          end

          let(:external_resource_dir) do
            "piyo"
          end

          let(:args) do
            "#{source} -o #{out_dir} -e #{external_resource_dir}".split(" ")
          end

          it "should raise Exception" do
            expect { Ajw2::Cli.execute(args) }.to raise_error
          end
        end
      end
    end
  end
end
