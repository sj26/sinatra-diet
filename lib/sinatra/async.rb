module Sinatra::Async
  def self.registered base
    base.send :include, InstanceMethods
  end
  
  module InstanceMethods
    # Repond to this request asynchronously.
    # 
    # Can be passed a block or method name which will be queued for
    # execution, or just aborts the current flow and presumes
    # you'll respond later.
    # 
    # The return value of the supplied block or method will be used
    # as a response, as per a normal Sinatra route handler, unless:
    # 
    #  * If it is an EM::Deferrable, we will respond as a succeed
    #    callback.
    # 
    #  * If it is nil, is an EM::Timer or EM::PeriodicTimer we
    #    presume you'll respond later using #async_respond.
    def async method_name=nil, &block
      raise RuntimeError, 'Not running in async capable server -- try Thin' unless env.has_key?('async.callback')
      
      block ||= method method_name if method_name
      
      if block
        EM.next_tick do
          catch :async do
            returned = invoke { route_eval &block }
            
            if returned.is_a? EventMachine::Deferrable
              returned.callback do |*args|
                invoke { throw :halt, args.first } unless args.empty?
                async_call!
              end
            elsif returned.is_a?(EventMachine::Timer) || returned.is_a?(EventMachine::PeriodicTimer)
              returned = nil
            end
            
            async_call! unless returned.nil?
          end
        end
      end
    
      throw :async
    end
    
    # Respond to an existing asynchronous request.
    def async_respond response
      invoke { throw :halt, response }
      async_call!
    end
  
    # Resumes #call! and sends an asynchronous response
    # 
    # To DRY this up we'd need to break up Sinatra::Base#call!
    def async_call!
      invoke { error_block! response.status }
    
      unless @response['Content-Type']
        if body.respond_to?(:to_ary) and body.first.respond_to? :content_type
          content_type body.first.content_type
        else
          content_type :html
        end
      end

      status, header, body = @response.finish

      # Never produce a body on HEAD requests. Do retain the Content-Length
      # unless it's "0", in which case we assume it was calculated erroneously
      # for a manual HEAD response and remove it entirely.
      if @env['REQUEST_METHOD'] == 'HEAD'
        body = []
        header.delete('Content-Length') if header['Content-Length'] == '0'
      end

      env['async.callback'].call [status, header, body]
    end
  end
end