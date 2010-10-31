require 'rubygems'
require 'sinatra/base'
require 'sinatra-diet'

class Application < Sinatra::Base
  register Sinatra::WebSocket
  
  def self.listeners
    @@listeners ||= []
  end
  
  def self.said
    @@said ||= []
  end
  
  def self.say what
    said << what
    EM.next_tick do
      listeners.each do |listener|
        listener.send_message what
      end
    end
  end
  
  websocket '/',
    :on_handshake => proc { |client| listeners << client },
    :on_message => proc { |client, message| say message },
    :on_close => proc { |client| listeners.delete client }
  
  get '/' do
    <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <title>Simple Chat</title>
        <script src="http://code.jquery.com/jquery.js"></script>
        <script type="text/javascript">
          jQuery(function ($) {
            var websocket = new WebSocket("#{request.url.sub(/^http/, 'ws')}"),
              $form = $('form'), $message = $('input[name="message"]', $form);
            websocket.onmessage = function(message) {
              $('#said').prepend(message.data + "\\n");
            };
            $form.submit(function () {
              websocket.send($message.val());
              $message.val("");
              return false;
            });
            $message.focus();
          });
        </script>
      </head>
      <body>
        <form action="/say" method="post">
          <input type="text" name="message" style="width: 100%;" />
          <pre id="said" style="height: 20em; overflow: auto; border: 1px inset;">#{self.class.said.reverse.collect { |message| message + "\n" }.join ''}</pre>
        </form>
      </body>
    </html>
    HTML
  end
  
  post '/say' do
    self.class.say params[:message]
    redirect '/'
  end
end

run Application
