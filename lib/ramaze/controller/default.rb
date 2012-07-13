module Ramaze
  Log.debug "Default controller invoked"

  ##
  # The default controller that is loaded if no other controllers have been
  # defined.
  #
  # @author Michael Fellinger
  # @since  30-03-2009
  #
  class DefaultController < Ramaze::Controller
    map '/'

    ##
    # Shows an ASCII lobster using Rack::Lobster::LobsterString.
    #
    # @author Michael Fellinger
    # @since  06-04-2009
    #
    def lobster
      require 'rack/lobster'
      respond Rack::Lobster::LobsterString
    end
  end # DefaultController
end # Ramaze
