require "spec_helper"

module Ajw2::Model::EventRenderer
  describe JavaScript do
    shared_examples_for "render successfully" do
      it { should be_an_instance_of String }

      it "should render JavaScript code" do
        expect(subject).to eq @fixture[:javascript]
      end
    end

    describe "#render_ajax" do
      context "which sets element value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets element text" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_text.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets integer value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_integer_value.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets decimal value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_decimal_value.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets datetime value" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_datetime_value.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets string literal" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_string_literal.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which sets integer literal" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_integer_literal.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which appends elements" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_append.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which appends elements with multiple values" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_multiple_append.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which reads record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_read.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which updates record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_update.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which deletes record" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_delete.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which hides element" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_hide_element.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which shows element" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_show_element.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which toggles element visibility" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_toggle_element.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which calls Web API" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_call_api.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "which calls JavaScript" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_call_script.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onload (ready) event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_ready.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onChange event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_onchange.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onFocus event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_onfocus.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onFocusOut event" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_onfocusout.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end
    end

    describe "#render_realtime" do
      context "with always-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onload (ready) source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always_ready.yml"))) }

        subject { Ajw2::Model::EventRenderer::JavaScript.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end
    end

    describe "#render_onmessage" do
      before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always.yml"))) }

      subject { Ajw2::Model::EventRenderer::JavaScript.new.render_onmessage(@fixture[:event]) }
      it { should be_an_instance_of String }

      it "should render JavaScript code" do
        expect(subject).to eq @fixture[:onmessage]
      end
    end
  end
end
