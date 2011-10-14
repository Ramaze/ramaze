module Ramaze
  module CoreExtensions
    # Extensions for Object
    module Object
      # returns a new clean binding for this object
      #
      # Usage:
      #
      #     eval 'self', object.scope  #=> returns object
      #
      def scope
        lambda{}
      end
    end # Object
  end # CoreExtensions
end # Ramaze
