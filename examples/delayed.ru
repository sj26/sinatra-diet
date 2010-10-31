require 'rubygems'
require 'sinatra/base'
require 'sinatra-diet'

class Application < Sinatra::Base
  register Sinatra::Async
  
  get '/' do
    async do
      EventMachine::Timer.new(2) do
        async_respond 'Hello, world!'
      end
    end
  end
end

run Application