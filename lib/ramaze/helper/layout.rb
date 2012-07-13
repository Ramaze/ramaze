module Ramaze
  module Helper
    ##
    # Provides wrapper methods for a higher-level approach than the core layout
    # method. The layout() method that comes with Innate/Ramaze is fairly basic
    # as it only allows you to specify a single layout to always use or a block
    # giving you some extra flexibility. The latter however is still a bit of a
    # pain when dealing with many custom layouts in a single controller. Meet
    # the Layout helper. This helper provides a single method (since April 2011,
    # it used to provide more) called "set_layout".  This method allows you to
    # specify a number of layouts and the methods for which these layouts should
    # be used.
    #
    # ## Examples
    #
    # The most basic example is simply setting a layout as you would do with the
    # layout() method:
    #
    #     set_layout 'default'
    #
    # This of course is very boring, time to add some more spices to our code:
    #
    #     set_layout 'default' => [:index]
    #
    # Woah! What just happened? It's quite easy actually, we merely defined that
    # the layout called "default" should be used for the index method *only*.
    # Pretty sweet huh? It gets even better:
    #
    #     set_layout 'default' => [:index, :edit], 'alternative' => [:add, :process]
    #
    # A few things changed. First of all there are now two key/value groups.
    # Each group defines a layout (the key) and a set of methods (the value) for
    # which each layout should be used. In this case the layout "default" will
    # be used for index() and edit() but the layout "alternative" will be used
    # for add() and process().
    #
    # Last but not least, multiple calls to set_layout will no longer override
    # any existing settings *unless* you actually specify the same method with a
    # different layout. This is possible because the set_layout method stores
    # all these details in an instance variable called "_ramaze_layouts".
    #
    # @author Yorick Peterse
    # @author Michael Fellinger
    # @author Pistos
    #
    module Layout

      ##
      # Extends the class that included this module so that the methods that
      # this helper provides can be called outside of instance of class methods.
      #
      # @param  [Object] into The class that included this module.
      # @author Michael Fellinger
      # @author Pistos
      #
      def self.included(into)
        into.extend SingletonMethods
      end

      module SingletonMethods
        ##
        # The set_layout method allows you to specify a number of methods and
        # their layout. This allows you to use layout A for methods 1, 2 and 3
        # but layout B for method 4.
        #
        # @example
        #  # The key is the layout, the value an array of methods
        #  set_layout 'default' => [:method_1], 'alternative' => [:method_2]
        #
        #  # We can combine this method with layout()
        #  layout 'default'
        #  set_layout 'alternative' => [:method_1]
        #
        #  # This is also perfectly fine
        #  set_layout 'default'
        #
        # @param  [String, Symbol, #to_hash] hash_or_layout
        #   In case it's a String or Symbol it will directly be used as the
        #   layout.
        #   When setting a Hash this hash should have it's keys set to the
        #   layouts and it's values to an array of methods that use the
        #   specific layout. For more information see the examples.
        #
        # @author Yorick Peterse
        # @author Michael Fellinger
        # @author Pistos
        # @since 2011-04-07
        #
        def set_layout(hash_or_layout)
          @_ramaze_layouts    ||= {}
          @_ramaze_old_layout ||= trait[:layout]

          # Extract the layout to use
          if hash_or_layout.respond_to?(:to_hash)
            # Invert the method/layout hash and save them so they don't get lost
            hash_or_layout.to_hash.each do |layout, layout_methods|
              layout_methods.each do |layout_method|
                @_ramaze_layouts[layout_method.to_s] = layout.to_s
              end
            end

            layout do |path, wish|
              path = path.to_s

              if @_ramaze_layouts.key?(path)
                use_layout = @_ramaze_layouts[path.to_s]
              # Use the old layout
              elsif @_ramaze_old_layout.respond_to?(:call)
                use_layout = @_ramaze_old_layout.call(path, wish)
              else
                use_layout = @_ramaze_old_layout
              end

              use_layout
            end
          else
            layout { |path| hash_or_layout }
          end
        end

        # @deprecated because it's not longer useful
        def set_layout_except(hash_or_layout)
          Ramaze.deprecated('set_layout_except', 'set_layout')
        end
      end # SingletonMethods
    end # Layout
  end # Helper
end # Ramaze
