require "spec_helper"
require "yaml"

module Ajw2::Model::Event
  describe Ruby do
    shared_examples_for "render successfully" do
      it { should be_an_instance_of String }

      it "should render Ruby code" do
        expect(subject).to eq @fixture[:ruby]
      end
    end

    describe "#render_ajax" do
      context "with always-execute source" do
        context "which sets element value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets element text" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_text.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets integer value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_integer_value.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets decimal value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_decimal_value.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets datetime value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_datetime_value.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets string literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_string_literal.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets integer literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_integer_literal.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which appends elements" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_append.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which reads record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_read.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which updates record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_update.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which deletes record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_delete.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which hides record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_hide_element.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which shows record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_show_element.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which toggles element visibility" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_toggle_element.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which call Web API" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_call_api.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onload (ready) event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_ready.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end
      end

      context "with conditional-execute source" do
        context "using equal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "using not-equal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional_neq.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "using less-than" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional_lt.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "using more-than" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional_gt.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end
      end
    end

    describe "#render_realtime" do
      context "with always-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always.yml"))) }

        subject { Ajw2::Model::Event::Ruby.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      describe "with conditional-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_conditional.yml"))) }

        subject { Ajw2::Model::Event::Ruby.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end

      describe "with onload (ready) source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always_ready.yml"))) }

        subject { Ajw2::Model::Event::Ruby.new.render_realtime(@fixture[:event]) }
        it_behaves_like "render successfully"
      end
    end
  end
end
