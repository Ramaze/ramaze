#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.
module Ramaze
  ##
  # Ramaze::Response is a small wrapper around Rack::Response that makes it
  # easier to send response data to the browser from a Ramaze application.
  #
  # @author Michael Fellinger
  # @since  01-03-2008
  #
  class Response < Rack::Response
    # Alias for Current.response
    def self.current; Current.response; end

    ##
    # Creates a new instance of the response class and processes the specified
    # parameters. Once this has been done it calls Rack::Response#initialize.
    #
    # @author Michael Fellinger
    # @since  01-03-2008
    # @param  [Array] body An array containing the data for the response body.
    # @param  [Fixnum] status The HTPP status code for the response.
    # @param  [Hash] header A hash containing additional headers and their
    #  values.
    # @param  [Proc] &block
    #
    def initialize(body = [], status = 200, header = {}, &block)
      modified_header = Ramaze.options.header.merge(header)
      header.merge!(modified_header)
      super
    end

    ##
    # Updates the body, status and headers.
    #
    # @author Michael Fellinger
    # @since  01-03-2008
    # @see    Ramaze::Response#initialize
    #
    def build(new_body = nil, new_status = nil, new_header = nil)
      self.header.merge!(new_header) if new_header

      self.body   = new_body   if new_body
      self.status = new_status if new_status
    end

    ##
    # Sets the body of the response to the given object.
    #
    # @author Michael Fellinger
    # @since  01-03-2008
    # @param  [Object] obj The object to use as the response body.
    #
    def body=(obj)
      if obj.respond_to?(:stat)
        @length = obj.stat.size
        @body   = obj
      elsif obj.respond_to?(:size)
        @body   = []
        @length = 0
        write(obj)
      else
        raise(ArgumentError, "Invalid body: %p" % obj)
      end
    end
  end # Response
end # Ramaze
