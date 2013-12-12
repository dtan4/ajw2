require "spec_helper"

module Ajw2::Model::Event
  describe JavaScript do
    before(:all) { load File.expand_path("../../../../fixtures/events_fixtures.rb", __FILE__) unless defined? AJAX_ALWAYS_SOURCE }

    describe "#render_ajax" do
      context "with always-execute source which set values" do
        subject { Ajw2::Model::Event::JavaScript.new.render_ajax(AJAX_ALWAYS_SOURCE[:events].first) }
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
      if (_response['_db_errors'].length == 0) {
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

      context "with always-execute source which append elements" do
        subject { Ajw2::Model::Event::JavaScript.new.render_ajax(AJAX_ALWAYS_SOURCE_APPEND[:events].first) }
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
      if (_response['_db_errors'].length == 0) {
        var if01 = _response['if01'];
        $('#messageTable').append($('<tr>').append($('<td>')).append($('<td>').val(if01['message'])));
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

      context "with onload (ready) event" do
        subject { Ajw2::Model::Event::JavaScript.new.render_ajax(AJAX_ALWAYS_SOURCE_READY[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
var message = $('#messageTextBox').val();
$.ajax({
  type: 'POST',
  url: '/event01',
  params: { 'message': message },
  success: function(_xhr_msg) {
    var _response = JSON.parse(_xhr_msg);
    if (_response['_db_errors'].length == 0) {
      var if01 = _response['if01'];
      $('#messageLabel').val(if01['message']);
    } else {
    }
  },
  error: function(_xhr, _xhr_msg) {
    alert(_xhr_msg);
  }
});
                                   EOS
        end
      end

      context "with conditional-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.render_ajax(AJAX_CONDITIONAL_SOURCE[:events].first) }
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
        if (_response['_db_errors'].length == 0) {
          var if01 = _response['if01'];
          $('#messageLabel').val(if01['message']);
        } else {
        }
      } else {
        if (_response['_db_errors'].length == 0) {
        } else {
        }
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

    describe "#render_realtime" do
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
        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(REALTIME_ALWAYS_SOURCE[:events].first) }
        it_behaves_like "with valid source"
      end

      context "with onload (ready) source" do
        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(REALTIME_ALWAYS_SOURCE_READY[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
var message = $('#messageTextBox').val();
var params = { 'message': message };
var request = { 'func': 'event01', 'params': params };
ws.send(JSON.stringfy(request));
                                   EOS
        end
      end

      context "with conditional-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.render_realtime(REALTIME_CONDITIONAL_SOURCE[:events].first) }
        it_behaves_like "with valid source"
      end
    end

    describe "#render_onmessage" do
      context "with always-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.render_onmessage(REALTIME_ALWAYS_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
case 'event01':
  var _response = _ws_json['msg'];
  if (_response['_db_errors'].length == 0) {
    var if01 = _response['if01'];
    $('#messageLabel').val(if01['message']);
  } else {
  }
  break;
                                   EOS
        end
      end

      context "with conditional-execute source" do
        subject { Ajw2::Model::Event::JavaScript.new.render_onmessage(REALTIME_CONDITIONAL_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render JavaScript code" do
          expect(subject).to eq(<<-EOS)
case 'event01':
  var _response = _ws_json['msg'];
  if (_response['result']) {
    if (_response['_db_errors'].length == 0) {
      var if01 = _response['if01'];
      $('#messageLabel').val(if01['message']);
    } else {
    }
  } else {
    if (_response['_db_errors'].length == 0) {
    } else {
    }
  }
  break;
                                   EOS
        end
      end
    end
  end
end
