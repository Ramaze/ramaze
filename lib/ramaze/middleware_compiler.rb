module Ramaze
  ##
  # @author Michael Fellinger
  # @since  14-03-2009
  # @see    Innate::MiddelwareCompiler
  #
  class MiddlewareCompiler < Innate::MiddlewareCompiler
    ##
    # Adds the path as a static file.
    #
    # @author Michael Fellinger
    # @since  26-03-2009
    # @param  [String] path The path to the static file to add.
    #
    def static(path)
      require 'rack/contrib'
      Rack::ETag.new(
        Rack::ConditionalGet.new(RackFileWrapper.new(path)), 'public'
      )
    end

    ##
    # Adds the path as a directory.
    #
    # @author Michael Fellinger
    # @since  26-03-2009
    # @param  [String] path The path to the directory to add.
    #
    def directory(path)
      require 'rack/contrib'
      Rack::ETag.new(
        Rack::ConditionalGet.new(Rack::Directory.new(path)), 'public'
      )
    end
  end # MiddlewareCompiler
end # Ramaze
