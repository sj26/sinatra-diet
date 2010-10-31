# Sinatra Diet

*Warning:* This is stuff I'm playing with, definitely not ready for anything production.

[Sinatra][sinatra] on a Diet gets [Thin][thin] and [Skinny][skinny], asynchronously

Sometimes Sinatra can get a bit fat--he's squeezing through the doorway, gets stuck, and nobody else can get through for a while. It's time to go on a diet to get [Thin][thin] and [Skinny][skinny].

One of Thin's greatest strength is asynchronous responses. This adds two ways to do so from within Sinatra: plain asynchronous responses and WebSockets (via [Skinny][skinny]).

This is actually two Sinatra extensions:

## Sinatra::Async

I know there's already [a sinatra-async extension](http://github.com/tmm1/async_sinatra) but I felt it was overly complex and didn't quite add what I wanted. My take on asynchronous Sinatra tried to be a little simpler. For the timeless classic:

    register Sinatra::Async
    
    get '/' do
      async do
        "Hello, World"
      end
    end

This literally just delays response to the next available EventMachine tick.

If you actually want to wait on a long-running asynchronous operation you have a couple of options. You can yield a deferrable and succeed it with the response:

    get '/long' do
      async do
        @deferrable = EM::Deferrable.new
      end
    end
    
    # somewhere else:
    @deferrable.succeed "Hello, world!"

You can also use a long-running operation which will call #async\_respond explicitly. EM::Timers, EM::PeriodicTimers and nil responses to an async block mean you'll call #async\_respond later:

    get '/long' do
      async do
        EventMachine::Timer.new(2) do
          async_respond 'Hello, world!'
        end
      end
    end

## Sinatra::WebSocket

Build websockets simply and easily using a Sinatra-inspired DSL:

    register Sinatra::Async
    
    websocket do |client, message|
      client.send "You said: #{message}"
    end

They catch GET websocket requests only, by default. You can also mount them on a path and give them explicit options:

    websocket '/hello',
      :on_handshake => proc do |client|
        client.send "Hi!"
        client.finish!
      end

The clients are Skinny::WebSocket instances, and you can supply any options you would normally pass to an instance in the handler call:

    websocket '/thing',
      :protocol => "adder",
      :on_message => proc do |client, message|
        client.send message.split(' ').compact.map(&:to_i).inject(0, &:+)
      end

Keep in mind that the proc callbacks supplied as options here are executed in the scope in which they're defined, here in the class scope of your sinatra app. This is _by design_--executing each handler inside a Sinatra instance means that instance (which is copied for every request) must hang around for the WebSocket connection's entire lifetime. If you want this, please implement it yourself.

Don't forget that the websocket client connection has a copy of the request's environment (as #env) which you can use inside callbacks.

## Caveats

*Be aware:* Long-running requests will keep a whole copy of your Sinatra app around until you complete them. Be careful to close every request and websocket you handle asynchronously or you'll find yourself in memory leak city.

This stuff only works on Thin. Patches for other EventMachine-based servers are welcome. Other wild and exotic servers are also considered, if you're brave! I'm looking at [ControlTower][controltower], mainly.

## TODO

 * Lightweight WebSocket channels.
 * ???
 * Profit

## Copyright

Copyright (c) 2010 Samuel Cochran. See LICENSE for details.

## P.S.

Do I get points for taking a metaphor too far?

  [controltower]: http://github.com/MacRuby/ControlTower
  [skinny]: http://github.com/sj26/skinny
  [sinatra]: http://github.com/sinatra/sinatra
  [thin]: http://github.com/macournoyer/thin
