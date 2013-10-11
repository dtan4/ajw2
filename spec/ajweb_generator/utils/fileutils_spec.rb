require "spec_helper"

module AjwebGenerator
  describe FileUtils do
    let(:filename) { "example.txt" }
    let(:text) { "hello, world!" }

    describe "#write_file" do
      context "when overwrite is true" do
        subject { AjwebGenerator::FileUtils.write_file(filename, text, true) }

        context "and file is not existed" do
          it { should be_true }
        end

        context "and file is already existed" do
          before { open(filename, "w") { |f| f.puts text} }
          it { should be_true }
          after { File.delete(filename) if File.exists?(filename) }
        end
      end

      context "when overwrite is false" do
        subject { AjwebGenerator::FileUtils.write_file(filename, text, false) }

        context "and file is not existed" do
          it { should be_true }
        end

        context "and file is already existed" do
          before { open(filename, "w") { |f| f.puts text } }
          it { should be_false }
          after { File.delete(filename) if File.exists?(filename) }
        end
      end
    end
  end
end
