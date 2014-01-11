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

    describe "#render_css_include" do
      subject { Ajw2::Model::Application.new(source).render_css_include }
      it { should be_kind_of String }

      it "should render Slim template" do
        expect(subject).to eq(<<-EOS)
link rel="stylesheet" type="text/css" href="/css/application.css"
link rel="stylesheet" type="text/css" href="http://example.com/sample.css"
                              EOS
      end
    end

    describe "#render_js_include" do
      subject { Ajw2::Model::Application.new(source).render_js_include }
      it { should be_kind_of String }

      it "should render Slim template" do
        expect(subject).to eq(<<-EOS)
script src="/js/application.js"
script src="http://example.com/sample.js"
                              EOS
      end
    end

    describe "#external_files" do
      context "when type is :css" do
        subject { Ajw2::Model::Application.new(source).external_files(:css) }
        it { should be_kind_of Array }

        it "should return the list of external CSS files" do
          expect(subject).to eq ["application.css"]
        end
      end

      context "when type is :js" do
        subject { Ajw2::Model::Application.new(source).external_files(:js) }
        it { should be_kind_of Array }

        it "should return the list of external JavaScript files" do
          expect(subject).to eq ["application.js"]
        end
      end

      context "when type is unknown" do
        subject { Ajw2::Model::Application.new(source).external_files(:hoge) }

        it "should raise ArgumentError" do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end
end
