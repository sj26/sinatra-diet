require 'rubygems'
require 'sinatra/base'
require 'sinatra-diet'

class Application < Sinatra::Base
  register Sinatra::Async
  
  get '/' do
    async do 
      'Hello, world!'
    end
  end
end

run Application