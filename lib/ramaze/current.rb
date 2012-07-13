module Ramaze
  ##
  # Class that's used to point to the current action. This can be useful if you
  # want to access data such as the session() method without having to include
  # Innate::Trinity (which can pollute your namespace and/or cause collisions).
  #
  # @author Michael Fellinger
  # @since  25-03-2009
  #
  class Current < Innate::Current
    ##
    # @author Michael Fellinger
    # @since  25-03-2009
    # @see    Innate::Current#setup
    def setup(env, request = Request, response = Response, session = Session)
      super
    end
  end # Current
end # Ramaze
