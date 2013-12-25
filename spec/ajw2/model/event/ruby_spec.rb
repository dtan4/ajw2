require "spec_helper"

module Ajw2::Model::Event
  describe Ruby do
    before(:all) { load File.expand_path("../../../../fixtures/events_fixtures.rb", __FILE__) unless defined? AJAX_ALWAYS_SOURCE }

    describe "#render_ajax" do
      context "with always-execute source which sets element value" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with always-execute source which sets element text" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE_TEXT[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with always-execute source which sets string literal" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE_STRING_LITERAL[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = "rawValue"
  db01 = Message.new(
    message: message
  )
  response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with always-execute source which sets integer literal" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE_INTEGER_LITERAL[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = 42
  db01 = Message.new(
    message: message
  )
  response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with always-execute source which appends elements" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE_APPEND[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with always-execute source which updates record" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE_DB_UPDATE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  newMessage = params[:newMessage]
  db01 = Message.where(
    message: message
  )
  db01.message = newMessage
  response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with always-execute source which deletes record" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_ALWAYS_SOURCE_DB_DELETE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  db01 = Message.where(
    message: message
  )
  db01.destroy
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with conditional-execute source using equal" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_CONDITIONAL_SOURCE[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  if (message == "hoge")
    db01 = Message.new(
      message: message
    )
    response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
    if response[:_db_errors].length == 0
      response[:if01] = {}
      response[:if01][:message] = message
    end
    response[:result] = true
  else
    if response[:_db_errors].length == 0
    end
    response[:result] = false
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with conditional-execute source using not-equal" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_CONDITIONAL_SOURCE_NEQ[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  if (message != "hoge")
    db01 = Message.new(
      message: message
    )
    response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
    if response[:_db_errors].length == 0
      response[:if01] = {}
      response[:if01][:message] = message
    end
    response[:result] = true
  else
    if response[:_db_errors].length == 0
    end
    response[:result] = false
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with conditional-execute source using less-than" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_CONDITIONAL_SOURCE_LT[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  if (message < "hoge")
    db01 = Message.new(
      message: message
    )
    response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
    if response[:_db_errors].length == 0
      response[:if01] = {}
      response[:if01][:message] = message
    end
    response[:result] = true
  else
    if response[:_db_errors].length == 0
    end
    response[:result] = false
  end
  response.to_json
end
                                   EOS
        end
      end

      context "with conditional-execute source using more-than" do
        subject { Ajw2::Model::Event::Ruby.new.render_ajax(AJAX_CONDITIONAL_SOURCE_GT[:events].first) }
        it { should be_an_instance_of String }

        it "should render Ruby code" do
          expect(subject).to eq(<<-EOS)
post "/event01" do
  content_type :json
  response = { _db_errors: [] }
  message = params[:message]
  if (message > "hoge")
    db01 = Message.new(
      message: message
    )
    response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
    if response[:_db_errors].length == 0
      response[:if01] = {}
      response[:if01][:message] = message
    end
    response[:result] = true
  else
    if response[:_db_errors].length == 0
    end
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
  response[:_db_errors] = []
  response[:_event] = "event01"
  message = params[:message]
  db01 = Message.new(
    message: message
  )
  response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
  if response[:_db_errors].length == 0
    response[:if01] = {}
    response[:if01][:message] = message
  end
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
  response[:_db_errors] = []
  response[:_event] = "event01"
  message = params[:message]
  if (message == "hoge")
    db01 = Message.new(
      message: message
    )
    response[:_db_errors] << { db01: db01.errors.full_messages } unless db01.save
    if response[:_db_errors].length == 0
      response[:if01] = {}
      response[:if01][:message] = message
    end
    response[:result] = true
  else
    if response[:_db_errors].length == 0
    end
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
