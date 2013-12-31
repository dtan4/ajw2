require "spec_helper"

module Ajw2::Model::Event
  describe JavaScript do
    describe "#render_ajax" do
      context "with always-execute source" do
        context "which sets element value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render JavaScript code" do
            expect(subject).to eq @fixture[:javascript]
          end
        end

        context "which sets element text" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_text.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render JavaScript code" do
            expect(subject).to eq @fixture[:javascript]
          end
        end

        context "which appends elements" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_append.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render JavaScript code" do
            expect(subject).to eq @fixture[:javascript]
          end
        end

        context "with onload (ready) event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_ready.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render JavaScript code" do
            expect(subject).to eq @fixture[:javascript]
          end
        end
      end

      context "with conditional-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:javascript]
        end
      end
    end

    describe "#render_realtime" do
      context "with always-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:javascript]
        end
      end

      context "with conditional-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_conditional.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:javascript]
        end
      end

      context "with onload (ready) source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always_ready.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:javascript]
        end
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
