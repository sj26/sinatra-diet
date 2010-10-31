require 'rubygems'
require 'sinatra/base'
require 'sinatra-diet'

class Application < Sinatra::Base
  register Sinatra::WebSocket
  
  get '/' do
    '<script>' +
    'var websocket = new WebSocket("ws://localhost:3000/echo");' +
    'websocket.onmessage=function(message){' +
    'document.getElementById(\'transcript\').innerHTML+=message.data+"\n";' +
    '}' +
    '</script>' +
    '<form onsubmit="websocket.send(this.message.value);this.message.value=\'\';return false">' +
    '<input name="message" type="text" />' +
    '</form>' +
    '<pre id="transcript"></pre>'
  end
  
  websocket '/echo' do |connection, message|
    connection.send_message "You said: #{message}"
  end
end

run Application