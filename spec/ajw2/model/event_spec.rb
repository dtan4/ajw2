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
        it "should render JavaScript code" do
          expect(method).to eq fixture[:javascript]
        end
      end

      let(:fixture) do
        symbolize_keys(YAML.load_file(fixture_path(fixture_name)))
      end

      let(:javascript) do
        described_class.new
      end

      describe "#render_ajax" do
        let(:method) do
          javascript.render_ajax(fixture[:event])
        end

        context "which sets element value" do
          let(:fixture_name) do
            "events/value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets element text" do
          let(:fixture_name) do
            "events/text.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets integer value" do
          let(:fixture_name) do
            "events/integer_value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets decimal value" do
          let(:fixture_name) do
            "events/decimal_value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets datetime value" do
          let(:fixture_name) do
            "events/datetime_value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets string literal" do
          let(:fixture_name) do
            "events/string_literal.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets integer literal" do
          let(:fixture_name) do
            "events/integer_literal.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which appends elements" do
          let(:fixture_name) do
            "events/append.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which appends elements with multiple values" do
          let(:fixture_name) do
            "events/multiple_append.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which reads record" do
          let(:fixture_name) do
            "events/db_read.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which updates record" do
          let(:fixture_name) do
            "events/db_update.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which deletes record" do
          let(:fixture_name) do
            "events/db_delete.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which hides element" do
          let(:fixture_name) do
            "events/hide_element.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which shows element" do
          let(:fixture_name) do
            "events/show_element.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which toggles element visibility" do
          let(:fixture_name) do
            "events/toggle_element.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which calls Web API" do
          let(:fixture_name) do
            "events/call_api.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which calls JavaScript" do
          let(:fixture_name) do
            "events/call_script.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onload (ready) event" do
          let(:fixture_name) do
            "events/ready.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onChange event" do
          let(:fixture_name) do
            "events/onchange.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onFocus event" do
          let(:fixture_name) do
            "events/onfocus.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onFocusOut event" do
          let(:fixture_name) do
            "events/onfocusout.yml"
          end

          it_behaves_like "render successfully"
        end
      end

      describe "#render_realtime" do
        let(:method) do
          javascript.render_realtime(fixture[:event])
        end

        context "with always-execute source" do
          let(:fixture_name) do
            "events/realtime.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onload (ready) source" do
          let(:fixture_name) do
            "events/realtime_onready.yml"
          end

          it_behaves_like "render successfully"
        end
      end

      describe "#render_onmessage" do
        let(:method) do
          javascript.render_onmessage(fixture[:event])
        end

        let(:fixture_name) do
          "events/realtime.yml"
        end

        it "should render JavaScript code" do
          expect(method).to eq fixture[:onmessage]
        end
      end
    end

    describe Event::Ruby do
      shared_examples_for "render successfully" do
        it "should render Ruby code" do
          expect(method).to eq fixture[:ruby]
        end
      end

      let(:fixture) do
        symbolize_keys(YAML.load_file(fixture_path(fixture_name)))
      end

      let(:ruby) do
        described_class.new
      end

      describe "#render_ajax" do
        let(:method) do
          ruby.render_ajax(fixture[:event])
        end

        context "which sets element value" do
          let(:fixture_name) do
            "events/value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets element text" do
          let(:fixture_name) do
            "events/text.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets integer value" do
          let(:fixture_name) do
            "events/integer_value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets decimal value" do
          let(:fixture_name) do
            "events/decimal_value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets datetime value" do
          let(:fixture_name) do
            "events/datetime_value.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets string literal" do
          let(:fixture_name) do
            "events/string_literal.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which sets integer literal" do
          let(:fixture_name) do
            "events/integer_literal.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which appends elements" do
          let(:fixture_name) do
            "events/append.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which appends elements with multiple values" do
          let(:fixture_name) do
            "events/multiple_append.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which reads record" do
          let(:fixture_name) do
            "events/db_read.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which updates record" do
          let(:fixture_name) do
            "events/db_update.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which deletes record" do
          let(:fixture_name) do
            "events/db_delete.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which hides record" do
          let(:fixture_name) do
            "events/hide_element.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which shows record" do
          let(:fixture_name) do
            "events/show_element.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which toggles element visibility" do
          let(:fixture_name) do
            "events/toggle_element.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which call Web API" do
          let(:fixture_name) do
            "events/call_api.yml"
          end

          it_behaves_like "render successfully"
        end

        context "which call JavaScript" do
          let(:fixture_name) do
            "events/call_script.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onload (ready) event" do
          let(:fixture_name) do
            "events/ready.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onChange event" do
          let(:fixture_name) do
            "events/onchange.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onFocus event" do
          let(:fixture_name) do
            "events/onfocus.yml"
          end

          it_behaves_like "render successfully"
        end

        context "with onFocusOut event" do
          let(:fixture_name) do
            "events/onfocusout.yml"
          end

          it_behaves_like "render successfully"
        end
      end

      describe "#render_realtime" do
        let(:method) do
          ruby.render_realtime(fixture[:event])
        end

        context "with always-execute source" do
          let(:fixture_name) do
            "events/realtime.yml"
          end

          it_behaves_like "render successfully"
        end

        describe "with onload (ready) source" do
          let(:fixture_name) do
            "events/realtime_onready.yml"
          end

          it_behaves_like "render successfully"
        end
      end
    end
  end
end
