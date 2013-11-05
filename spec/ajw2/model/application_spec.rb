require "spec_helper"

module Ajw2
  describe Application do
    let(:app) { Ajw2::Application.new }
    let(:dirname) { "outdir" }
    let(:default_html) { "/index.html" }
    let(:default_css) { "/index.css" }
    let(:default_js) { "/index.js" }

    before(:all) do
      pending
    end

    describe "#generate" do
      it "should call Application#html_generate" do
        app.should_receive(:html_generate)
        app.generate(dirname)
      end

      it "should call Application#js_generate" do
        app.should_receive(:js_generate)
        app.generate(dirname)
      end

      it "should call Application#css_generate" do
        app.should_receive(:css_generate)
        app.generate(dirname)
      end

      it "should call Application#db_generate" do
        app.should_receive(:db_generate)
        app.generate(dirname)
      end
    end

    describe "#html_generate" do
    end

    describe "#css_generate" do
    end

    describe "#js_generate" do
    end

    describe "#db_generate" do
    end

    after(:each) do
      [default_html, default_css, default_js].map do |nm|
        dirname << nm
      end.each do |name|
        File.delete(name) if File.exists?(name)
      end
    end
  end
end
