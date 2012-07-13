#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'logger'

module Ramaze
  module Logger
    ##
    # Informer for the Stdlib Logger.
    #
    class Logger < ::Logger

      ##
      # Integration to Logging
      #
      # @param [String] tag
      # @param [Hash] args
      #
      def log(tag, *args)
        __send__(tag, args.join("\n"))
      end

      ##
      # Stub for compatibility
      #
      # @param [Hash] args
      def dev(*args)
        debug(*args)
      end
    end # Logger
  end # Logger
end # Ramaze
