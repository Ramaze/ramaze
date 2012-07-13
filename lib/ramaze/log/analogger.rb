#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'swiftcore/Analogger/Client'

module Ramaze
  module Logger
    
    ##
    # Informer for the Swiftcore Analogger logging system.
    #
    # You can find it at http://analogger.swiftcore.org and install with
    # gem install analogger
    #
    class Analogger < ::Swiftcore::Analogger::Client
      include Logging

      # identifier for your application
      trait :name => 'walrus'

      # Host analogger runs on
      trait :host => '127.0.0.1'

      # Port analogger runs on
      trait :port => 6766

      ##
      # Create a new instance, parameters default to the traits.
      #
      # @param [String] name The name of the logging system (can be anything you like).
      # @param [String] host The IP/hostname on which the logging system is running.
      # @param [Integer] port The port of the logging system.
      #
      def initialize(name = class_trait[:name], host = class_trait[:host], 
      port = class_trait[:port])
        super
      end

      ##
      # Integration to Logging
      #
      # @param [String] tag
      # @param [Hash] args
      #
      def log(tag, *args)
        super(tag, args.join("\n"))
      end
    end # Analogger
  end # Log
end # Ramaze
