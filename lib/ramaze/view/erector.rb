Ramaze.setup(:verbose => false) do
  gem 'erector'
end

module Ramaze
  module View
    ##
    # Adapter for Erector. Erector is a view engine that works a bit like
    # Markably but offers a much more pleasant way of building your views. By
    # creating classes in plain ruby you can generate layouts and views without
    # having to write a single line of HTML.
    #
    # Each layout or view is a simple class that matches the filename. A layout
    # named "default.erector" would result in a class with the name "Default".
    # It's *very* important to know that you should ALWAYS extend
    # Ramaze::View::Erector.  Without extending this class you won't be able to
    # use Erector at all.
    #
    # When working with the Erector adapter there are a few things you'll need
    # to know. First all your views and layouts should be classes as explained
    # earlier on. Each class should have at least a single method named
    # "content". This method is executed by Erector and the HTML it produces
    # will either be stored in the @content instance variable (if it's a view)
    # or sent to the browser if it's a layout.  The @content variable can be
    # displayed by calling the rawtext() method and passing the variable as it's
    # parameter.
    #
    # Using helper methods, such as the render_* methods is also possible
    # although slightly different than you're used to. Due to the way the
    # Erector adapter works it isn't possible to directly call a helper method.
    # As a workaround you can access these methods from the "@controller"
    # instance variable. Don't forget to render the output of these helpers
    # using rawtext(). Feel free to submit any patches if you think you have a
    # better solution so that developers don't have to use the @controller
    # instance variable.
    #
    # @example
    #   # This is the code for the layout
    #   class Default < Erector::Widget
    #     html do
    #       head do
    #         title 'Erector Layout'
    #       end
    #
    #       body do
    #         rawtext @content
    #       end
    #
    #     end
    #   end
    #
    #   # And here's the view
    #   class Index < Erector::Widget
    #     def content
    #       h2 'This is the view'
    #     end
    #   end
    #
    #   # Render an extra view
    #   class ExtraView < Erector::Widget
    #     def content
    #       rawtext @controller.render_view :some_extra_view
    #     end
    #   end
    #
    # @author  Yorick Peterse
    #
    module Erector
      # Include the Erector gem. By doing this Erector views can extend the
      # Erector gem without causing any namespace errors.
      include ::Erector

      ##
      # The call method is called whenever a view is loaded. A view can either
      # be a layout or an actual view since they're treated the same way. First
      # the view is loaded, followed by the layout.
      #
      # @author Yorick Peterse
      # @param [Object] action Object containing a copy of the current Action
      #  class data.
      # @param [String] string The content of the currently loaded layout. This
      #  variable isn't used by the Erector adapter but is required since Ramaze
      #  expects 2 parameters. Usually this string is used to inline load (or
      #  evaluate) the content of a view.
      # @return [String] The generated HTML.
      #
      def self.call action, string
        # Return the contents unless a view has been defined
        return string, 'text/html' unless action.view

        # Evaluate the class so we can use it. The content of "string"
        # is a full blown class that should always have a "content" method.
        #eval string, action.binding
        eval string

        # Generate the class name based on the filename.
        # Class names are a CamelCased version of the filename (without the
        # extension).
        klass    = File.basename action.view, '.erector'
        klass    = klass.camel_case
        view_obj = self.const_get(klass)

        # Synchronize the methods of action.instance with the view. These
        # methods can be accessed by calling @controller.METHOD
        action.variables[:controller] = action.instance

        # Now that we have all the data we can start rendering the HTML.
        # Note that we pass the action.variables hash to the new() method. This
        # is done to give the view access to all existing (instance) variables.
        # Syncing them using action.copy_variables didn't seem to do the trick.
        html = view_obj.new(action.variables).to_html

        # All done
        return html, 'text/html'
      end
    end # Erector
  end # View
end # Ramaze
