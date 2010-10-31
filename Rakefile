require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sinatra-diet"
    gem.summary = %Q{Sinatra on a Diet gets Thin and Skinny}
    gem.description = %Q{Sinatra can be aynchronous and provide WebSockets using Thin and Skinny.}
    gem.email = "sj26@sj26.com"
    gem.homepage = "http://github.com/sj26/sinatra-diet"
    gem.authors = ["Samuel Cochran"]
    
    gem.add_dependency "sinatra", ">= 0"
    gem.add_dependency "thin", ">= 0"
    gem.add_dependency "skinny", ">= 0.1.2"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
