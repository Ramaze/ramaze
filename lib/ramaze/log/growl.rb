#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'ruby-growl'

module Ramaze
  module Logger
    ##
    # Informer for the Growl notification system
    # Growl lets Mac OS X applications unintrusively tell you when things happen.
    #
    # Growl can be downloaded from the following website: http://growl.info/
    #
    class Growl < ::Growl
      include Innate::Traited
      include Logging
      
      trait :defaults => {
        :name             => 'walrus'   ,
        :host             => 'localhost',
        :password         => 'walrus'   ,
        :all_notifies     => %w[error warn debug info dev],
        :default_notifies => %w[error warn info]
      }

      ##
      # Takes the options from the default trait for merging.
      #
      # @param [Hash] options A hash containing extra options to use when 
      #  initializing the Growl logger.
      #
      def initialize(options = {})
        options = class_trait[:defaults].merge(options).values_at(
          :host, :name, :all_notifies, :default_notifies, :password
        )
        
        super(*options)
      end

      ##
      # Integration to Logging
      #
      # @param [String] tag
      # @param [Hash] args
      #
      def log(tag, *args)
        begin
          notify(tag.to_s, Time.now.strftime("%X"), args.join("\n")[0..100])
        rescue Errno::EMSGSIZE
          # Send size was to big (not really), ignore
        end
      end
    end # Growl
  end # Logger
end # Ramaze
