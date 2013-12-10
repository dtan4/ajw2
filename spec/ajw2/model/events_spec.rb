require "spec_helper"

module Ajw2::Model
  describe Events do
    before do
      @ajax_source = {
                      events: [{ id: "event01", realtime: false }]
                     }
      @realtime_source = {
                          events: [{ id: "event01", realtime: true }]
                         }

      @js = double("js",
                   ajax_event: (<<-EOS),
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    params: { 'message': message },
    success: function(_xhr_msg) {
      var _response = JSON.parse(_xhr_msg);
      var if01 = _response['if01'];
      $('#messageLabel').val(if01['message']);
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
EOS
                   realtime_event: (<<-EOS),
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  var params = { 'message': message };
  var request = { 'func': 'event01', 'params': params };
  ws.send(JSON.stringfy(request));
});
EOS
                   onmessage: (<<-EOS))
case 'event01':
  var _response = _ws_json['msg'];
  var if01 = _response['if01'];
  $('#messageLabel').val(if01['message']);
  break;
EOS

      @rb = double("rb",
                   ajax_event: (<<-EOS),
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
                   realtime_event: (<<-EOS))
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

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Events.new(@ajax_source) }
        its(:source) { should be_instance_of Hash }
      end

      context "with non-Hash" do
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new("a") }.to raise_error ArgumentError,
            "Events section must be a Hash"
        end
      end
    end

    describe "#render_rb_ajax" do
      context "with valid source" do
        subject { Ajw2::Model::Events.new(@ajax_source, @js, @rb).render_rb_ajax }
        it { should be_kind_of Array }
        it { should have(1).item }

        it "should render Ruby code" do
          expect(subject[0]).to eq <<-EOS
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
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new({}).render_rb_ajax }.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_rb_realtime" do
      context "with valid source" do
        subject { Ajw2::Model::Events.new(@realtime_source, @js, @rb).render_rb_realtime }
        it { should be_kind_of Array }
        it { should have(1).item }

        it "should render Ruby code" do
          expect(subject[0]).to eq <<-EOS
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
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new({}).render_rb_realtime }.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_js_ajax" do
      context "with valid source" do
        subject { Ajw2::Model::Events.new(@ajax_source, @js, @rb).render_js_ajax }
        it { should be_kind_of Array }
        it { should have(1).item }

        it "should render JavaScript code" do
          expect(subject[0]).to eq <<-EOS
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    params: { 'message': message },
    success: function(_xhr_msg) {
      var _response = JSON.parse(_xhr_msg);
      var if01 = _response['if01'];
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
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new({}).render_js_ajax }.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_js_realtime" do
      context "with valid source" do
        subject { Ajw2::Model::Events.new(@realtime_source, @js, @rb).render_js_realtime }
        it { should be_kind_of Array }
        it { should have(1).item }

        it "should render JavaScript code" do
          expect(subject[0]).to eq <<-EOS
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  var params = { 'message': message };
  var request = { 'func': 'event01', 'params': params };
  ws.send(JSON.stringfy(request));
});
          EOS
        end
      end

      context "with invalid source" do
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new({}).render_js_realtime }.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end

    describe "#render_js_onmessage" do
      context "with valid source" do
        subject { Ajw2::Model::Events.new(@realtime_source, @js, @rb).render_js_onmessage }
        it { should be_kind_of Array }
        it { should have(1).item }

        it "should render JavaScript code" do
          expect(subject[0]).to eq <<-EOS
case 'event01':
  var _response = _ws_json['msg'];
  var if01 = _response['if01'];
  $('#messageLabel').val(if01['message']);
  break;
          EOS
        end
      end

      context "with invalid source" do
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new({}).render_js_onmessage }.to raise_error RuntimeError, "/events/events is not found"
        end
      end
    end
  end
end
