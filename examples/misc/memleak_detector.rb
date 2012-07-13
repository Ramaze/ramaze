#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'ramaze'

# This little app helps me track down memory-leaks in Ramaze.

class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end
end

def memcheck(top = 10, klass = Object)
  puts
  os = Hash.new(0)
  ObjectSpace.each_object(klass){|o| yield(os, o) }
  pp sorted = os.sort_by{|k,v| -v }.first(top)
  puts

  return sorted
rescue Exception => ex
  puts ex
ensure
  GC.start
end

Thread.new do
  loop do
    # memcheck(10, String){|os, o| os[o] += 1 }
    memcheck{|os, o| os[o.class] += 1 }
    sleep 5
  end
end

Ramaze::Log.loggers.clear
Ramaze.start :adapter => :webrick, :mode => :live
