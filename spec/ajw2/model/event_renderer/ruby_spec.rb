require "spec_helper"
require "yaml"

module Ajw2::Model::EventRenderer
  describe Ruby do
    shared_examples_for "render successfully" do
      it { should be_an_instance_of String }

      it "should render Ruby code" do
        expect(subject).to eq @fixture[:ruby]
      end
    end

    describe "#render_ajax" do
      context "which sets element value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/value.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets element text" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/text.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets integer value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/integer_value.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets decimal value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/decimal_value.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets datetime value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/datetime_value.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets string literal" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/string_literal.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets integer literal" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/integer_literal.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which appends elements" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/append.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which appends elements with multiple values" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/multiple_append.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which reads record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_read.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which updates record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_update.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which deletes record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_delete.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which hides record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/hide_element.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which shows record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/show_element.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which toggles element visibility" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/toggle_element.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which call Web API" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/call_api.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which call JavaScript" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/call_script.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onload (ready) event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/ready.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onChange event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onchange.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onFocus event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onfocus.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onFocusOut event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onfocusout.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end
    end

    describe "#render_realtime" do
      context "with always-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      describe "with onload (ready) source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_onready.yml"))) }

        subject { Ajw2::Model::EventRenderer::Ruby.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end
    end
  end
end
