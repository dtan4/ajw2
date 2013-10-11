require "spec_helper"

module AjwebGenerator
  describe FileUtils do
    let(:filename) { "example.txt" }
    let(:text) { "hello, world!" }
    let(:exist_text) { "goodby, world!" }

    describe "#write_file" do
      context "when file is not existed" do
        context "and overwrite is true" do
          let(:result) { AjwebGenerator::FileUtils.write_file(filename, text, true) }

          it "should return true" do
            result.should be_true
          end
        end

        context "and overwrite is false" do
          let(:result) { AjwebGenerator::FileUtils.write_file(filename, text, false) }

          it "should return true" do
            result.should be_true
          end
        end
      end

      context "when file is already existed" do
        before do
          open(filename, "w") { |f| f.puts exist_text }
        end

        context "and overwrite is true" do
          let(:result) { AjwebGenerator::FileUtils.write_file(filename, text, true) }

          it "should return true" do
            result.should be_true
          end
        end

        context "and overwrite is false" do
          let(:result) { AjwebGenerator::FileUtils.write_file(filename, text, false) }

          it "should return false" do
            result.should be_false
          end
        end

        after do
          File.delete(filename) if File.exists?(filename)
        end
      end
    end
  end
end
