require "spec_helper"
require "fileutils"

module Ajw2
  describe Cli do
    describe "#execute" do
      context "with valid argument" do
        context "simple chat application" do
          before do
            @source = fixture_path("chat.json")
            @out_dir = "test_cli"
            @external_file_dir = "test_ext_files"
            @args = [@source, @out_dir, @external_file_dir]
            FileUtils.rm_r(@out_dir) if Dir.exists? @out_dir
          end

          subject { Ajw2::Cli.execute(@args) }

          it "should create out_dir" do
            subject
            expect(Dir.exists?(@out_dir)).to be_true
          end

          after do
            FileUtils.rm_r(@out_dir) if Dir.exists? @out_dir
          end
        end

        pending "calendar application" do
          before do
            @source = fixture_path("calendar.json")
            @out_dir = "test_cli"
            @external_file_dir = "test_ext_files"
            @args = [@source, @out_dir, @external_file_dir]
            FileUtils.rm_r(@out_dir) if Dir.exists? @out_dir
          end

          subject { Ajw2::Cli.execute(@args) }

          it "should create out_dir" do
            subject
            expect(Dir.exists?(@out_dir)).to be_true
          end

          after do
            FileUtils.rm_r(@out_dir) if Dir.exists? @out_dir
          end
        end
      end

      context "with invalid argument" do
        before do
          @source = "hoge"
          @out_dir = "fuga"
          @external_file_dir = "piyo"
          @args = [@source, @out_dir, @external_file_dir]
        end

        it "should raise Exception" do
          expect { Ajw2::Cli.execute(@args) }.to raise_error
        end
      end
    end
  end
end
