require "spec_helper"

module Ajw2::Model
  describe Events do
    before(:all) { load File.expand_path("../../../fixtures/events_fixtures.rb", __FILE__) }

    describe "#initialize" do
      context "with Hash" do
        subject { Ajw2::Model::Events.new(AJAX_ALWAYS_SOURCE) }
        its(:source) { should be_instance_of Hash }
p      end

      context "with non-Hash" do
        it "should raise Exception" do
          expect { Ajw2::Model::Events.new("a") }.to raise_error ArgumentError,
            "Events section must be a Hash"
        end
      end
    end

    describe "#render_rb_ajax" do
      context "with always-execute source" do
        subject { Ajw2::Model::Events.new(AJAX_ALWAYS_SOURCE).render_rb_ajax }
        it { should be_an_instance_of Array }
        it { should have(1).item }

        it "should render Ruby code" do
          expect(subject[0]).to eq(<<-EOS)
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

      context "with conditional-execute source" do
        subject { Ajw2::Model::Events.new(AJAX_CONDITIONAL_SOURCE).render_rb_ajax }
        it { should be_an_instance_of Array }
        it { should have(1).item }

        it "should render Ruby code" do
          expect(subject[0]).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = {}
  message = params[:message]
  if (message == "hoge")
    db01 = Message.new(
      message: message
    )
    db01.save
    response[:message] = message
    response[:result] = true
  else
    response[:result] = false
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with invalid source" do

      end
    end

    describe "#render_rb_realtime" do
      context "with always-execute source" do
        subject { Ajw2::Model::Events.new(REALTIME_ALWAYS_SOURCE).render_rb_realtime }
        it { should be_an_instance_of Array }
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

      pending "with conditional-execute source" do
        subject { Ajw2::Model::Events.new(REALTIME_CONDITIONAL_SOURCE).render_rb_realtime }
        it { should be_an_instance_of Array }
        it { should have(1).item }
      end

      context "with invalid source" do

      end
    end

    describe "#render_js_ajax" do
      context "with always-execute source" do
        subject { Ajw2::Model::Events.new(AJAX_ALWAYS_SOURCE).render_js_ajax }
        it { should be_an_instance_of Array }
        it { should have(1).item }

        it "should render JavaScript code" do
          expect(subject[0]).to eq(<<-EOS)
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    params: { 'message': message },
    success: function(_xhr_msg) {
      var _xhr_json = JSON.parse(_xhr_msg);
      var if01 = _xhr_json['if01'];
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

      context "with conditional-execute source" do
        subject { Ajw2::Model::Events.new(AJAX_CONDITIONAL_SOURCE).render_js_ajax }
        it { should be_an_instance_of Array }
        it { should have(1).item }

        it "should render JavaScript code" do
          expect(subject[0]).to eq(<<-EOS)
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    params: { 'message': message },
    success: function(_xhr_msg) {
      var _xhr_json = JSON.parse(_xhr_msg);
      if (_xhr_json['result']) {
        var if01 = _xhr_json['if01'];
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

      context "with invalid source" do

      end
    end

    pending "#render_js_realtime" do
      context "with always-execute source" do
        subject { Ajw2::Model::Events.new(REALTIME_ALWAYS_SOURCE).render_js_realtime }
        it { should be_an_instance_of Array }
        it { should have(1).item }
      end

      context "with conditional-execute source" do
        subject { Ajw2::Model::Events.new(REALTIME_CONDITIONAL_SOURCE).render_js_realtime }
        it { should be_an_instance_of Array }
        it { should have(1).item }
      end

      context "with invalid source" do

      end
    end
  end
end
