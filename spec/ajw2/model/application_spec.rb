require "spec_helper"

module Ajw2::Model
  describe Application do
    let(:source) {
      {
       name: "sample",
       css: [
             { remote: false, src: "application.css" },
             { remote: true, src: "http://example.com/sample.css" }
            ],
       js: [
             { remote: false, src: "application.js" },
             { remote: true, src: "http://example.com/sample.js" }
           ]
      }
    }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Application.new(source) }

        describe '#source' do
          subject { super().source }
          it { is_expected.to be_instance_of Hash }
        end
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
        it { is_expected.to be_an_instance_of String }

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
        it { is_expected.to be_an_instance_of String }

        it "should return Slim template" do
          expect(subject).to eq(<<-EOS)
meta charset="utf-8"
title
  | &lt;script&gt;alert(&#39;xss&#39;);&lt;/script&gt;
EOS
        end
      end
    end

    describe "#render_css_include" do
      subject { Ajw2::Model::Application.new(source).render_css_include }
      it { is_expected.to be_kind_of String }

      it "should render Slim template" do
        expect(subject).to eq(<<-EOS)
link rel="stylesheet" type="text/css" href="/css/application.css"
link rel="stylesheet" type="text/css" href="http://example.com/sample.css"
                              EOS
      end
    end

    describe "#render_js_include" do
      subject { Ajw2::Model::Application.new(source).render_js_include }
      it { is_expected.to be_kind_of String }

      it "should render Slim template" do
        expect(subject).to eq(<<-EOS)
script src="/js/application.js"
script src="http://example.com/sample.js"
                              EOS
      end
    end

    describe "#external_local_files" do
      context "when type is :css" do
        subject { Ajw2::Model::Application.new(source).external_local_files(:css, File.dirname(__FILE__)) }
        it { is_expected.to be_kind_of Array }

        it "should return the list of external CSS files" do
          expect(subject).to eq [File.expand_path("application.css", File.dirname(__FILE__))]
        end
      end

      context "when type is :js" do
        subject { Ajw2::Model::Application.new(source).external_local_files(:js, File.dirname(__FILE__)) }
        it { is_expected.to be_kind_of Array }

        it "should return the list of external JavaScript files" do
          expect(subject).to eq [File.expand_path("application.js", File.dirname(__FILE__))]
        end
      end

      context "when type is unknown" do
        subject { Ajw2::Model::Application.new(source).external_local_files(:hoge, File.dirname(__dir__)) }

        it "should raise ArgumentError" do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end
end
