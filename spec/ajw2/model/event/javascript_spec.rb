require "spec_helper"

module Ajw2::Model::Event
  describe JavaScript do
    shared_examples_for "render successfully" do
      it { should be_an_instance_of String }

      it "should render JavaScript code" do
        expect(subject).to eq @fixture[:javascript]
      end
    end

    describe "#render_ajax" do
      context "with always-execute source" do
        context "which sets element value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets element text" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_text.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets string literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_string_literal.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets integer literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_integer_literal.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which appends elements" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_append.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which reads record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_read.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which updates record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_update.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which deletes record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_delete.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which hide element" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_hide_element.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which show element" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_show_element.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which toggle element visibility" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_show_element.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onload (ready) event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_ready.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end
      end

      context "with conditional-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
        it_behaves_like "render successfully"
      end
    end

    describe "#render_realtime" do
      context "with always-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with conditional-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_conditional.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      context "with onload (ready) source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always_ready.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end
    end

    describe "#render_onmessage" do
      context "with always-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_onmessage(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:onmessage]
        end
      end

      context "with conditional-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_conditional.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_onmessage(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:onmessage]
        end
      end
    end
  end
end
