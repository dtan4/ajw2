require "spec_helper"

module Ajw2::Model::Event
  describe JavaScript do
    before(:all) { load File.expand_path("../../../../fixtures/events_fixtures.rb", __FILE__) }

    describe "#ajax_event" do
      context "with always-execute source which set values" do
        subject { Ajw2::Model::Event::JavaScript.new.ajax_event(AJAX_ALWAYS_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
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

      context "with always-execute source which append elements" do
        subject { Ajw2::Model::Event::JavaScript.new.ajax_event(AJAX_ALWAYS_SOURCE_APPEND[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    params: { 'message': message },
    success: function(_xhr_msg) {
      var _response = JSON.parse(_xhr_msg);
      var if01 = _response['if01'];
      $('#messageTable').append($('<tr>').append($('<td>')).append($('<td>').val(if01['message'])));
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
                                   EOS
        end
      end

      context "with conditional-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.ajax_event(AJAX_CONDITIONAL_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    params: { 'message': message },
    success: function(_xhr_msg) {
      var _response = JSON.parse(_xhr_msg);
      if (_response['result']) {
        var if01 = _response['if01'];
        $('#messageLabel').val(if01['message']);
      } else {
      }
    },
    error: function(_xhr, _xhr_msg) {
      alert(_xhr_msg);
    }
  });
});
                                   EOS
        end
      end
    end

    describe "#realtime_event" do
      shared_examples_for "with valid source" do
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  var params = { 'message': message };
  var request = { 'func': 'event01', 'params': params };
  ws.send(JSON.stringfy(request));
});
                                   EOS
        end
      end

      context "with always-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.realtime_event(REALTIME_ALWAYS_SOURCE[:events].first) }
        it_behaves_like "with valid source"
      end

      context "with conditional-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.realtime_event(REALTIME_CONDITIONAL_SOURCE[:events].first) }
        it_behaves_like "with valid source"
      end
    end

    describe "#onmessage" do
      context "with always-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.onmessage(REALTIME_ALWAYS_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
case 'event01':
  var _response = _ws_json['msg'];
  var if01 = _response['if01'];
  $('#messageLabel').val(if01['message']);
  break;
                                   EOS
        end
      end

      context "with conditional-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.onmessage(REALTIME_CONDITIONAL_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
case 'event01':
  var _response = _ws_json['msg'];
  if (_response['result']) {
    var if01 = _response['if01'];
    $('#messageLabel').val(if01['message']);
  } else {
  }
  break;
                                   EOS
        end
      end
    end
  end
end
