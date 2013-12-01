require "spec_helper"

module Ajw2::Model
  describe Application do
    let(:source) {
      {
       name: "sample"
      }
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Application.new(source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should raise ArgumentError" do
          expect { Ajw2::Model::Application.new("a") }.to raise_error ArgumentError,
            "Application section must be a Hash"
        end
      end
    end

    describe "#render_header" do
      context "with clean source" do
        subject { Ajw2::Model::Application.new(source).render_header }
        it { should be_an_instance_of String }

        it "should return Slim template" do
          expect(subject).to eq(<<-EOS)
meta charset="utf-8"
title
  | sample
EOS
        end
      end

      context "with dirty source (include XSS)" do
        before do
          @dirty_source = source
          @dirty_source[:name] = "<script>alert('xss');</script>"
        end

        subject { Ajw2::Model::Application.new(source).render_header }
        it { should be_an_instance_of String }

        it "should return Slim template" do
          expect(subject).to eq(<<-EOS)
meta charset="utf-8"
title
  | &lt;script&gt;alert(&#39;xss&#39;);&lt;/script&gt;
EOS
        end
      end
    end
  end
end
