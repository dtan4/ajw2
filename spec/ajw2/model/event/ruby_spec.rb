require "spec_helper"
require "yaml"

module Ajw2::Model::Event
  describe Ruby do
    describe "#render_ajax" do
      context "with always-execute source" do
        context "which sets element value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "which sets element text" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_text.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "which sets string literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_string_literal.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "which sets integer literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_integer_literal.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "which appends elements" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_append.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "which updates record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_update.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "which deletes record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_db_delete.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "which call Web API" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/always_call_api.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end
      end

      context "with conditional-execute source" do
        context "using equal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "using not-equal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional_neq.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "using less-than" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional_lt.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end

        context "using more-than" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/conditional_gt.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it { should be_an_instance_of String }

          it "should render Ruby code" do
            expect(subject).to eq @fixture[:ruby]
          end
        end
      end
    end

    describe "#render_realtime" do
      context "with always-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_always.yml"))) }

        subject { Ajw2::Model::Event::Ruby.new.render_realtime(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq @fixture[:ruby]
        end
      end

      describe "with conditional-execute source" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_conditional.yml"))) }

        subject { Ajw2::Model::Event::Ruby.new.render_realtime(@fixture[:event]) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq @fixture[:ruby]
        end
      end
    end
  end
end
