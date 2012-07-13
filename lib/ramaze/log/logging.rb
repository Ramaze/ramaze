#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  ##
  # This module provides a basic skeleton for your own loggers to be compatible.
  # 
  # @example
  #   class MyLogger
  #     include Logging
  #
  #     def log(tag, *args)
  #       p tag => args
  #     end
  #   end
  #
  module Logging
    ##
    # Takes the tag (:warn|:debug|:error|:info) and the name of a method to be
    # called upon elements of msgs that don't respond to :to_str
    # Goes on and sends the tag and transformed messages each to the #log method.
    # If you include this module you have to define #log or it will raise.
    #
    # @param [String] tag The level of the log message.
    # @param [String] method 
    # @param [Array] msgs The data that should be logged.
    #
    def tag_log(tag, meth, *msgs)
      msgs.each do |msg|
        string = (msg.respond_to?(:to_str) ? msg : msg.send(meth))
        log(tag, string)
      end
    end

    ##
    # Converts everything given to strings and passes them on with :info
    #
    # @param [Array] objects An array of objects that need to be converted to 
    #  strings.
    #
    def info(*objects)
      tag_log(:info, :to_s, *objects)
    end

    ##
    # Converts everything given to strings and passes them on with :warn
    #
    # @param [Array] objects An array of objects that need to be converted to 
    #  strings.
    #
    def warn(*objects)
      tag_log(:warn, :to_s, *objects)
    end

    ##
    # Inspects objects if they are no strings. Tag is :debug
    #
    # @param [Array] objects An array of objects that will be inspected.
    #
    def debug(*objects)
      tag_log(:debug, :inspect, *objects)
    end

    ##
    # Inspects objects if they are no strings. Tag is :dev
    #
    # @param [Array] objects An array of objects that will be inspected.
    #
    def dev(*objects)
      tag_log(:dev, :inspect, *objects)
    end

    alias << debug

    ##
    # Takes either an Exception or just a String, formats backtraces to be a bit
    # more readable and passes all of this on to tag_log :error
    #
    # @param [Object] ex The exception that was raised.
    #
    def error(ex)
      if ex.respond_to?(:exception)
        message = ex.backtrace
        message.map!{|m| m.to_s.gsub(/^#{Regexp.escape(Dir.pwd)}/, '.') }
        message.unshift(ex.inspect)
      else
        message = ex.to_s
      end
      tag_log(:error, :to_s, *message)
    end

    ##
    # Nothing.
    #
    # THINK: Is this really required? It doesn't do anything anyway.
    #
    def shutdown
    end

    ##
    # Stub for WEBrick
    #
    def debug?
      false
    end
  end # Logging
end # Ramaze
