require "spec_helper"

module AjwebGenerator
  describe FileUtils do
    before(:all) do
      @filename = "example.txt"
      @text = "hello, world!"
      @exist_text = "goodby, world!"
    end

    describe "#write_file" do
      context "when file is not existed" do
        context "and overwrite is true" do
          before(:all) do
            @result = AjwebGenerator::FileUtils.write_file(@filename, @text, true)
          end

          it "should return true" do
            @result.should be_true
          end

          it "should create file" do
            File.exists?(@filename).should be_true
          end

          it "should have specified text" do
            open(@filename).read.strip.should == @text
          end

          after(:all) do
            File.delete(@filename) if File.exists?(@filename)
          end
        end

        context "and overwrite is false" do
          before(:all) do
            @result = AjwebGenerator::FileUtils.write_file(@filename, @text, false)
          end

          it "should return true" do
            @result.should be_true
          end

          it "should create file" do
            File.exists?(@filename).should be_true
          end

          it "should have specified text" do
            open(@filename).read.strip.should == @text
          end

          after(:all) do
            File.delete(@filename) if File.exists?(@filename)
          end
        end
      end

      context "when file is already existed" do
        before(:all) do
          open(@filename, "w") { |f| f.puts @exist_text }
        end

        context "and overwrite is true" do
          before(:all) do
            @result = AjwebGenerator::FileUtils.write_file(@filename, @text, true)
          end

          it "should return true" do
            @result.should be_true
          end

          it "should create file" do
            File.exists?(@filename).should be_true
          end

          it "should have specified text" do
            open(@filename).read.strip.should == @text
          end
        end

        context "and overwrite is false" do
          before(:all) do
            @result = AjwebGenerator::FileUtils.write_file(@filename, @text, false)
          end

          it "should return false" do
            @result.should be_false
          end
        end

        after(:all) do
          File.delete(@filename) if File.exists?(@filename)
        end
      end
    end
  end
end
