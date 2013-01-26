#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
#          Copyright (c) 2008 rob@rebeltechnologies.nl
# All files in this distribution are subject to the terms of the MIT license.

require 'syslog'

module Ramaze
  module Logger
    ##
    # Logger class for writing to syslog. It is a *very* thin wrapper
    # around the Syslog library.
    #
    class Syslog
      include Logging

      # Hash containing various method aliases. Rbx and Jruby don't seem to like
      # the combination of alias() and module_function() so this works around
      # that.
      ALIASES = {:dev => :debug, :warn => :warning, :error => :err}

      ##
      # Open the syslog library, if it is already open, we reopen it using the
      # new argument list. The argument list is passed on to the Syslog library
      # so please check that, and man syslog for detailed information.
      #
      # There are 3 parameters:
      #
      # * ident:  The identification used in the log file, defaults to $0
      # * options:  defaults to  Syslog::LOG_PID | Syslog::LOG_CONS
      # * facility: defaults to Syslog::LOG_USER
      #
      def initialize(*args)
        ::Syslog.close if ::Syslog.opened?
        ::Syslog.open(*args)
      end

      ##
      # Just sends all messages received to ::Syslog
      # We simply return if the log was closed for some reason, this behavior
      # was copied from Informer.  We do not handle levels here. This will
      # be done by the syslog daemon based on it's configuration.
      def log(tag, *messages)
        return if !::Syslog.opened?
        tag = tag.to_sym

        if ALIASES.key?(tag)
          tag = ALIASES[tag]
        end

        messages = messages.map {|m| m.gsub(/(%[^m])/,'%\1')}
        ::Syslog.send(tag, *messages)
      end

      ##
      # Has to call the modules singleton-method.
      #
      def inspect
        ::Syslog.inspect
      end
    end # Syslog
  end # Logger
end # Ramaze
