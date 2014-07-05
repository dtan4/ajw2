require "spec_helper"

module Ajw2::Model
  describe Application do
    let(:source) do
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
    end

    let(:dirty_source) do
      {
        name: "<script>alert('xss');</script>",
        css: [
          { remote: false, src: "application.css" },
          { remote: true, src: "http://example.com/sample.css" }
        ],
        js: [
          { remote: false, src: "application.js" },
          { remote: true, src: "http://example.com/sample.js" }
        ]
      }
    end

    let(:application) do
      described_class.new(source)
    end

    describe "#initialize" do
      let(:application) do
        described_class.new(arg)
      end

      context "with Hash" do
        let(:arg) do
          source
        end

        it "should an instance of Application" do
          expect(application).to be_a described_class
        end
      end

      context "with non-Hash" do
        let(:arg) do
          "a"
        end

        it "should raise ArgumentError" do
          expect do
            application
          end.to raise_error ArgumentError, "Application section must be a Hash"
        end
      end
    end

    describe "#render_header" do
      let(:render_header) do
        application.render_header
      end

      context "with clean source" do
        it "should return Slim template" do
          expect(render_header).to eq(<<-EOS)
meta charset="utf-8"
title
  | sample
EOS
        end
      end

      context "with dirty source (include XSS)" do
        let(:source) do
          dirty_source
        end

        it "should return Slim template" do
          expect(render_header).to eq(<<-EOS)
meta charset="utf-8"
title
  | &lt;script&gt;alert(&#39;xss&#39;);&lt;/script&gt;
EOS
        end
      end
    end

    describe "#render_css_include" do
      let(:render_css_include) do
        application.render_css_include
      end

      it "should render Slim template" do
        expect(render_css_include).to eq(<<-EOS)
link rel="stylesheet" type="text/css" href="/css/application.css"
link rel="stylesheet" type="text/css" href="http://example.com/sample.css"
                              EOS
      end
    end

    describe "#render_js_include" do
      let(:render_js_include) do
        application.render_js_include
      end

      it "should render Slim template" do
        expect(render_js_include).to eq(<<-EOS)
script src="/js/application.js"
script src="http://example.com/sample.js"
                              EOS
      end
    end

    describe "#external_local_files" do
      let(:external_local_files) do
        application.external_local_files(type, dir)
      end

      let(:dir) do
        File.dirname(__FILE__)
      end

      context "when type is :css" do
        let(:type) do
          :css
        end

        it "should return the list of external CSS files" do
          expect(external_local_files).to match_array [File.expand_path("application.css", File.dirname(__FILE__))]
        end
      end

      context "when type is :js" do
        let(:type) do
          :js
        end

        it "should return the list of external CSS files" do
          expect(external_local_files).to match_array [File.expand_path("application.js", File.dirname(__FILE__))]
        end
      end

      context "when type is unknown" do
        let(:type) do
          :hoge
        end

        it "should raise ArgumentError" do
          expect { external_local_files }.to raise_error ArgumentError
        end
      end
    end
  end
end
