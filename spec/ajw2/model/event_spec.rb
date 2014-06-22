require "spec_helper"

module Ajw2::Model
  describe Event do
    let(:ajax_source) do
      { events: [{ id: "event01", type: "ajax" }] }
    end

    let(:realtime_source) do
      { events: [{ id: "event01", type: "realtime" }] }
    end

    let(:invalid_source) do
      {}
    end

    let(:js) do
      double("js",
             render_ajax: (<<-EOS),
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    data: { 'message': message },
    beforeSend: function(_xhr) {
      _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
    },
    success: function(_xhr_msg) {
      var if01 = _xhr_msg['if01'];
      $('#messageLabel').val(if01['message']);
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
EOS
             render_realtime: (<<-EOS),
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  var params = { 'message': message };
  var request = { 'func': 'event01', 'params': params };
  ws.send(JSON.stringify(request));
});
EOS
render_onmessage: (<<-EOS))
case 'event01':
  var _response = _ws_json['msg'];
  var if01 = _response['if01'];
  $('#messageLabel').val(if01['message']);
  break;
EOS
    end

    let(:rb) do
      double("rb",
             render_ajax: (<<-EOS),
post "/event01" do
  content_type :json
  response = {}
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  db01.save
  response[:message] = message
  response.to_json
end
EOS
             render_realtime: (<<-EOS))
when "event01"
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  db01.save
  response[:message] = message
  EventMachine.next_tick do
    settings.sockets.each { |s| s.send(response.to_json) }
  end
EOS
    end

    let(:event) do
      described_class.new(source, js, rb)
    end

    describe "#initialize" do
      let(:event) do
        described_class.new(arg, js, rb)
      end

      context "with Hash" do
        let(:arg) do
          ajax_source
        end

        it "should be an instance of Event" do
          expect(event).to be_a described_class
        end
      end

      context "with non-Hash" do
        let(:arg) do
          "a"
        end

        it "should raise Exception" do
          expect do
            event
          end.to raise_error ArgumentError, "Event section must be a Hash"
        end
      end
    end

    describe "#render_rb_ajax" do
      let(:render_rb_ajax) do
        event.render_rb_ajax
      end

      context "with valid source" do
        let(:source) do
          ajax_source
        end

        it "has 1 item" do
          expect(render_rb_ajax.size).to eq(1)
        end

        it "should render Ruby code" do
          expect(render_rb_ajax[0]).to eq <<-EOS
post "/event01" do
  content_type :json
  response = {}
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  db01.save
  response[:message] = message
  response.to_json
end
          EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_rb_ajax
          end.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_rb_realtime" do
      let(:render_rb_realtime) do
        event.render_rb_realtime
      end

      context "with valid source" do
        let(:source) do
          realtime_source
        end

        it "has 1 item" do
          expect(render_rb_realtime.size).to eq(1)
        end

        it "should render Ruby code" do
          expect(render_rb_realtime[0]).to eq <<-EOS
when "event01"
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  db01.save
  response[:message] = message
  EventMachine.next_tick do
    settings.sockets.each { |s| s.send(response.to_json) }
  end
          EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_rb_realtime
          end.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_js_ajax" do
      let(:render_js_ajax) do
        event.render_js_ajax
      end

      context "with valid source" do
        let(:source) do
          ajax_source
        end

        it "has 1 item" do
          expect(render_js_ajax.size).to eq(1)
        end

        it "should render JavaScript code" do
          expect(render_js_ajax[0]).to eq <<-EOS
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    data: { 'message': message },
    beforeSend: function(_xhr) {
      _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
    },
    success: function(_xhr_msg) {
      var if01 = _xhr_msg['if01'];
      $('#messageLabel').val(if01['message']);
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
          EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_js_ajax
          end.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_js_realtime" do
      let(:render_js_realtime) do
        event.render_js_realtime
      end

      context "with valid source" do
        let(:source) do
          realtime_source
        end

        it "has 1 item" do
          expect(render_js_realtime.size).to eq(1)
        end

        it "should render JavaScript code" do
          expect(render_js_realtime[0]).to eq <<-EOS
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  var params = { 'message': message };
  var request = { 'func': 'event01', 'params': params };
  ws.send(JSON.stringify(request));
});
          EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_js_realtime
          end.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_js_onmessage" do
      let(:render_js_onmessage) do
        event.render_js_onmessage
      end

      context "with valid source" do
        let(:source) do
          realtime_source
        end

        it "has 1 item" do
          expect(render_js_onmessage.size).to eq(1)
        end

        it "should render JavaScript code" do
          expect(render_js_onmessage[0]).to eq <<-EOS
case 'event01':
  var _response = _ws_json['msg'];
  var if01 = _response['if01'];
  $('#messageLabel').val(if01['message']);
  break;
          EOS
        end
      end

      context "with invalid source" do
        let(:source) do
          invalid_source
        end

        it "should raise Exception" do
          expect do
            render_js_onmessage
          end.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe Event::JavaScript do
      shared_examples_for "render successfully" do
        it { is_expected.to be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:javascript]
        end
      end

      describe "#render_ajax" do
        context "which sets element value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/value.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets element text" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/text.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets integer value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/integer_value.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets decimal value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/decimal_value.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets datetime value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/datetime_value.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets string literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/string_literal.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets integer literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/integer_literal.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which appends elements" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/append.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which appends elements with multiple values" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/multiple_append.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which reads record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_read.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which updates record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_update.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which deletes record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_delete.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which hides element" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/hide_element.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which shows element" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/show_element.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which toggles element visibility" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/toggle_element.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which calls Web API" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/call_api.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which calls JavaScript" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/call_script.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onload (ready) event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/ready.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onChange event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onchange.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onFocus event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onfocus.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onFocusOut event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onfocusout.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end
      end

      describe "#render_realtime" do
        context "with always-execute source" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onload (ready) source" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_onready.yml"))) }

          subject { Ajw2::Model::Event::JavaScript.new.render_realtime(@fixture[:event]) }
          it_behaves_like "render successfully"
        end
      end

      describe "#render_onmessage" do
        before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime.yml"))) }

        subject { Ajw2::Model::Event::JavaScript.new.render_onmessage(@fixture[:event]) }
        it { is_expected.to be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq @fixture[:onmessage]
        end
      end
    end

    describe Event::Ruby do
      shared_examples_for "render successfully" do
        it { is_expected.to be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq @fixture[:ruby]
        end
      end

      describe "#render_ajax" do
        context "which sets element value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/value.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets element text" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/text.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets integer value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/integer_value.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets decimal value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/decimal_value.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets datetime value" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/datetime_value.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets string literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/string_literal.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which sets integer literal" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/integer_literal.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which appends elements" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/append.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which appends elements with multiple values" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/multiple_append.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which reads record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_read.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which updates record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_update.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which deletes record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/db_delete.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which hides record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/hide_element.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which shows record" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/show_element.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which toggles element visibility" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/toggle_element.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which call Web API" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/call_api.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "which call JavaScript" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/call_script.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onload (ready) event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/ready.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onChange event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onchange.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onFocus event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onfocus.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        context "with onFocusOut event" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/onfocusout.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_ajax(@fixture[:event]) }
          it_behaves_like "render successfully"
        end
      end

      describe "#render_realtime" do
        context "with always-execute source" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_realtime(@fixture[:event]) }
          it_behaves_like "render successfully"
        end

        describe "with onload (ready) source" do
          before(:all) { @fixture = symbolize_keys(YAML.load_file(fixture_path("events/realtime_onready.yml"))) }

          subject { Ajw2::Model::Event::Ruby.new.render_realtime(@fixture[:event]) }
          it_behaves_like "render successfully"
        end
      end
    end
  end
end
