require "spec_helper"
require "fileutils"

module Ajw2
  describe Cli do
    describe "#execute" do
      context "with valid argument" do
        before do
          @source = fixture_path("chat.json")
          @out_dir = "test_cli"
          @args = [@source, @out_dir]
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

      context "with invalid argument" do
        before do
          @source = "hoge"
          @out_dir = "fuga"
          @args = [@source, @out_dir]
        end

        it "should raise Exception" do
          expect { Ajw2::Cli.execute(@args) }.to raise_error
        end
      end
    end
  end
end
