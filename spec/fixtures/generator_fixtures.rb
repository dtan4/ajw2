RENDER_CSS_INCLUDE = <<-EOS
link rel="stylesheet" type="text/css" href="/css/ext/application.css"
EOS

RENDER_JS_INCLUDE = <<-EOS
script src="/js/ext/application.js"
EOS

RENDER_MIGRATION = [
                    {
                     tablename: "users",
                     up: (<<-EOS),
create_table :users do |t|
  t.string :name
  t.string :password
end
                                                EOS
                     down: "drop_table :users"
                    },
                    {
                     tablename: "messages",
                     up: (<<-EOS),
create_table :messages do |t|
  t.integer :user_id
  t.string :message
end
                                                EOS
                     down: "drop_table :messages"
                    }
                   ]

RENDER_DEFINITION = [
                     (<<-EOS),
class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :password
end
EOS
                     (<<-EOS),
class Message < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :message
end
EOS
                    ]

RENDER_RB_AJAX = [
                  (<<-EOS)
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
                 ]

RENDER_RB_REALTIME = [
                      (<<-EOS)
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
                     ]

RENDER_JS_AJAX = [
                  (<<-EOS)
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  $.ajax({
    type: 'POST',
    url: '/event01',
    data: { 'message': message },
    beforeSend: function(_xhr) {
      _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
    },
    success: function(_msg) {
      var if01 = _msg['if01'];
      $('#messageLabel').val(if01['message']);
    },
    error: function(_xhr, _msg) {
      alert('XMLHttpRequest Error: ' + _msg);
    }
  });
});
EOS
                 ]

RENDER_JS_REALTIME = [
                      (<<-EOS)
$('#submitBtn').click(function() {
  var message = $('#messageTextBox').val();
  var params = { 'message': message };
  var request = { 'func': 'event01', 'params': params };
  ws.send(JSON.stringfy(request));
});
EOS
                     ]

RENDER_JS_ONMESSAGE = [
                       (<<-EOS)
case 'event01':
  var if01 = _msg['if01'];
  $('#messageLabel').val(if01['message']);
  break;
EOS
                      ]

APP_RB = <<-EOS
class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :password
end

class Message < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :message
end

class App < Sinatra::Base
  configure do
    register Sinatra::ActiveRecordExtension
    set :sockets, []
    use Rack::Session::Cookie, expire_after: 3600, secret: "salt"
    use Rack::Csrf, raise: true
    Slim::Engine.default_options[:pretty] = true
  end

  helpers do
    def csrf_meta_tag
      Rack::Csrf.csrf_metatag(env)
    end
  end

  get "/" do
    if !request.websocket?
      slim :index
    else
      request.websocket do |ws|
        ws.onopen do
          settings.sockets << ws
        end

        ws.onmessage do |msg|
          _ws_json = JSON.parse(msg)
          response = {}
          case _ws_json["func"]
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
          else
          end
        end

        ws.onclose do
          settings.sockets.delete(ws)
        end
      end
    end
  end

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
end
          EOS

APP_RB_AJAX_ONLY = <<-EOS
class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :password
end

class Message < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :message
end

class App < Sinatra::Base
  configure do
    register Sinatra::ActiveRecordExtension
    set :sockets, []
    use Rack::Session::Cookie, expire_after: 3600, secret: "salt"
    use Rack::Csrf, raise: true
    Slim::Engine.default_options[:pretty] = true
  end

  helpers do
    def csrf_meta_tag
      Rack::Csrf.csrf_metatag(env)
    end
  end

  get "/" do
    if !request.websocket?
      slim :index
    else
      request.websocket do |ws|
        ws.onopen do
          settings.sockets << ws
        end

        ws.onmessage do |msg|
          _ws_json = JSON.parse(msg)
          response = {}
        end

        ws.onclose do
          settings.sockets.delete(ws)
        end
      end
    end
  end

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
end
          EOS

APP_RB_REALTIME_ONLY = <<-EOS
class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :password
end

class Message < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :message
end

class App < Sinatra::Base
  configure do
    register Sinatra::ActiveRecordExtension
    set :sockets, []
    use Rack::Session::Cookie, expire_after: 3600, secret: "salt"
    use Rack::Csrf, raise: true
    Slim::Engine.default_options[:pretty] = true
  end

  helpers do
    def csrf_meta_tag
      Rack::Csrf.csrf_metatag(env)
    end
  end

  get "/" do
    if !request.websocket?
      slim :index
    else
      request.websocket do |ws|
        ws.onopen do
          settings.sockets << ws
        end

        ws.onmessage do |msg|
          _ws_json = JSON.parse(msg)
          response = {}
          case _ws_json["func"]
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
          else
          end
        end

        ws.onclose do
          settings.sockets.delete(ws)
        end
      end
    end
  end

end
          EOS

APP_RB_NOEVENT = <<-EOS
class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :password
end

class Message < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :message
end

class App < Sinatra::Base
  configure do
    register Sinatra::ActiveRecordExtension
    set :sockets, []
    use Rack::Session::Cookie, expire_after: 3600, secret: "salt"
    use Rack::Csrf, raise: true
    Slim::Engine.default_options[:pretty] = true
  end

  helpers do
    def csrf_meta_tag
      Rack::Csrf.csrf_metatag(env)
    end
  end

  get "/" do
    if !request.websocket?
      slim :index
    else
      request.websocket do |ws|
        ws.onopen do
          settings.sockets << ws
        end

        ws.onmessage do |msg|
          _ws_json = JSON.parse(msg)
          response = {}
        end

        ws.onclose do
          settings.sockets.delete(ws)
        end
      end
    end
  end

end
          EOS

LAYOUT_SLIM = <<-EOS
doctype html
html
  head
    meta charset="utf-8"
    == csrf_meta_tag
    title sample
    link rel="stylesheet" type="text/css" href="/css/ext/application.css"
  html
    == yield
    script src="/js/jquery.min.js"
    script src="/js/app.js"
    script src="/js/ext/application.js"
          EOS

INDEX_SLIM = <<-EOS
h1 sample
          EOS

DATABASE_YML = <<-EOS
development:
  database: sample_development

test:
  database: sample_test

production:
  database: sample_production
          EOS

CREATE_USERS_RB = <<-EOS
class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
      t.string :password
    end
  end

  def down
    drop_table :users
  end
end
          EOS

CREATE_MESSAGES_RB = <<-EOS
class CreateMessages < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.integer :user_id
      t.string :message
    end
  end

  def down
    drop_table :messages
  end
end
          EOS

APP_JS = <<-EOS
$(function() {
  var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
  var _csrf_token = $('meta[name=_csrf]').attr('content');

  $('#submitBtn').click(function() {
    var message = $('#messageTextBox').val();
    $.ajax({
      type: 'POST',
      url: '/event01',
      data: { 'message': message },
      beforeSend: function(_xhr) {
        _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
      },
      success: function(_msg) {
        var if01 = _msg['if01'];
        $('#messageLabel').val(if01['message']);
      },
      error: function(_xhr, _msg) {
        alert('XMLHttpRequest Error: ' + _msg);
      }
    });
  });
  $('#submitBtn').click(function() {
    var message = $('#messageTextBox').val();
    var params = { 'message': message };
    var request = { 'func': 'event01', 'params': params };
    ws.send(JSON.stringfy(request));
  });

  ws.onmessage = function(_msg) {
    switch (_msg['_event']) {
    case 'event01':
      var if01 = _msg['if01'];
      $('#messageLabel').val(if01['message']);
      break;
    }
  };
});
         EOS

APP_JS_AJAX_ONLY = <<-EOS
$(function() {
  var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
  var _csrf_token = $('meta[name=_csrf]').attr('content');

  $('#submitBtn').click(function() {
    var message = $('#messageTextBox').val();
    $.ajax({
      type: 'POST',
      url: '/event01',
      data: { 'message': message },
      beforeSend: function(_xhr) {
        _xhr.setRequestHeader("X-CSRF-Token", _csrf_token);
      },
      success: function(_msg) {
        var if01 = _msg['if01'];
        $('#messageLabel').val(if01['message']);
      },
      error: function(_xhr, _msg) {
        alert('XMLHttpRequest Error: ' + _msg);
      }
    });
  });

  ws.onmessage = function(_msg) {
  };
});
         EOS

APP_JS_REALTIME_ONLY = <<-EOS
$(function() {
  var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
  var _csrf_token = $('meta[name=_csrf]').attr('content');

  $('#submitBtn').click(function() {
    var message = $('#messageTextBox').val();
    var params = { 'message': message };
    var request = { 'func': 'event01', 'params': params };
    ws.send(JSON.stringfy(request));
  });

  ws.onmessage = function(_msg) {
    switch (_msg['_event']) {
    case 'event01':
      var if01 = _msg['if01'];
      $('#messageLabel').val(if01['message']);
      break;
    }
  };
});
         EOS

APP_JS_NOEVENT = <<-EOS
$(function() {
  var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
  var _csrf_token = $('meta[name=_csrf]').attr('content');


  ws.onmessage = function(_msg) {
  };
});
         EOS
