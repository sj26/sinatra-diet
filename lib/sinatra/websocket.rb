require 'skinny'

module Sinatra::WebSocket
  WEBSOCKET_OPTIONS = [:protocol, :on_open, :on_start, :on_handshake, :on_message, :on_error, :on_finish, :on_close]
  
  def self.registered base
    base.send :include, Skinny::Helpers
  end
  
  def websocket path='*', options={}, &block
    # No nice way to do this in core?
    websocket_options = options.select { |key, value| WEBSOCKET_OPTIONS.include? key }
    options.reject! { |key, value| WEBSOCKET_OPTIONS.include? key }
    
    condition { websocket? }
    
    route 'GET', path, options do
      websocket! websocket_options.dup, &block
      throw :async
    end
  end
end