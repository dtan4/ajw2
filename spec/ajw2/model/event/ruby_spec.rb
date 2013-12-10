require "spec_helper"

module Ajw2::Model::Event
  describe Ruby do
    before(:all) { load File.expand_path("../../../../fixtures/events_fixtures.rb", __FILE__) }

    describe "#render_ajax" do
      context "with always-execute source" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
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
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_CONDITIONAL_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
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
    end

    describe "#render_realtime" do
      context "with always-execute source" do
        subject { Ajw2::Model::Event::Ruby.new.render_realtime(REALTIME_ALWAYS_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq <<-EOS
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

      describe "with conditional-execute source" do
        subject { Ajw2::Model::Event::Ruby.new.render_realtime(REALTIME_CONDITIONAL_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq <<-EOS
when "event01"
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
  EventMachine.next_tick do
    settings.sockets.each { |s| s.send(response.to_json) }
  end
                                   EOS
        end
      end
    end
  end
end
