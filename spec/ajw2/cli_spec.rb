require "spec_helper"
require "fileutils"

module Ajw2
  describe Cli do
    describe "#execute" do
      context "with valid argument" do
        shared_examples_for "execute successfully" do
          before(:all) { Ajw2::Cli.execute(@args) }

          it "should create out_dir" do
            expect(Dir.exist?(@out_dir)).to be_truthy
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
              expect(File.exist?(File.expand_path(path, @out_dir))).to be_truthy
            end
          end

          after(:all) { FileUtils.rm_r(@out_dir) if Dir.exist? @out_dir }
        end

        context "2 arguments" do
          before(:all) do
            @source = fixture_path("chat.json")
            @out_dir = "test_cli"
            @args = "#{@source} -o #{@out_dir}".split(" ")
            FileUtils.rm_r(@out_dir) if Dir.exist? @out_dir
          end

          it_behaves_like "execute successfully"
        end

        context "3 arguments" do
          before(:all) do
            @source = fixture_path("chat.json")
            @out_dir = "test_cli"
            @external_resource_dir = "test_ext_files"
            @args = "#{@source} -o #{@out_dir} -e #{@external_resource_dir}".split(" ")
            FileUtils.rm_r(@out_dir) if Dir.exist? @out_dir
          end

          it_behaves_like "execute successfully"
        end

        context "long options" do
          before(:all) do
            @source = fixture_path("chat.json")
            @out_dir = "test_cli"
            @external_resource_dir = "test_ext_files"
            @args = "#{@source} --output #{@out_dir} --external #{@external_resource_dir}".split(" ")
            FileUtils.rm_r(@out_dir) if Dir.exist? @out_dir
          end

          it_behaves_like "execute successfully"
        end
      end

      context "with invalid argument" do
        context "invalid arguments count" do
          before { @args = [] }

          it "should raise ArgumentError" do
            expect { Ajw2::Cli.execute(@args) }.to raise_error ArgumentError
          end
        end

        context "invalid value" do
          before do
            @source = "hoge"
            @out_dir = "fuga"
            @external_resource_dir = "piyo"
            @args = "#{@source} -o #{@out_dir} -e #{@external_resource_dir}".split(" ")
          end

          it "should raise Exception" do
            expect { Ajw2::Cli.execute(@args) }.to raise_error
          end
        end
      end
    end
  end
end
