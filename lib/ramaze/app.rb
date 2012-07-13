module Ramaze
  # An application is a collection of controllers and options that have a common
  # name.  Every application has a location it dispatches from, this behaves
  # similar to Rack::URLMap.
  AppMap = Innate::URLMap.new

  #:nodoc:
  def self.to(object)
    app_name = object.ancestral_trait[:app]
    App[app_name].to(object)
  end

  ##
  # App is the superclass for applications and acts as their prototype when it
  # comes to configuration.
  #
  # An application consists of options, a location, and a list of objects. The
  # objects are usually {Ramaze::Controller}s.
  #
  # The options are inherited, the basics are set in Ramaze.options, from there
  # to Ramaze::App.options, and finally into every instance of App.
  #
  # This allows to collect {Ramaze::Controller}s of your application into a
  # common group that can easily be used in other applications, while retaining
  # the original options.
  #
  # Every instance of {App} is mapped in {AppMap}, which is the default
  # location to #call from Rack.
  #
  # Additionally, every {App} can have custom locations for
  # root/public/view/layout directories, which allows reuse beyond directory
  # boundaries.
  #
  # In contrast to Innate, where all Nodes share the same middleware, {App}
  # also has a subset of middleware that handles serving static files, routes
  # and rewrites.
  #
  # To indicate that a {Ramaze::Controller} belongs to a specific application,
  # you can pass a second argument to {Ramaze::Controller::map}
  #
  # @example adding Controller to application
  #   class WikiController < Ramaze::Controller
  #     map '/', :wiki
  #   end
  #
  # The App instance will be created for you and if you don't use any other
  # applications in your code there is nothing else you have to do. Others can
  # now come and simply reuse your code in their own applications.
  #
  # There is some risk of name collisions if everybody calls their app `:wiki`,
  # but given that you only use one foreign app of this kind might give less
  # reason for concern.
  #
  # If you still try to use two apps with the same name, you have to be
  # careful, loading one first, renaming it, then loading the second one.
  #
  # The naming of an App has no influence on any other aspects of dispatching
  # or configuration.
  #
  class App
    include Innate::Optioned

    # options not found here will be looked up in Ramaze.options
    options.dsl do
      o "Unique identifier for this application",
        :name, :pristine
    end

    APP_LIST = {}

    attr_reader :name, :location, :url_map, :options

    ##
    # Finds or creates an application for the given name and URI.
    #
    # @author Michael Fellinger
    # @param  [String] name The name of the application.
    # @param  [String] location The URI to which the app is mapped.
    # @return [Ramaze::App]
    #
    def self.find_or_create(name, location = nil)
      location = '/' if location.nil? && name == :pristine
      self[name] || new(name, location)
    end

    ##
    # Returns the application for the given name.
    #
    # @author Michael Fellinger
    # @param  [String] name The name of the application.
    # @return [Ramaze::App]
    #
    def self.[](name)
      APP_LIST[name.to_sym]
    end

    ##
    # Creates a new instance of the application and sets the name and location.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    # @param  [String] name The name of the application.
    # @param  [String] location The location to which the application is mapped.
    #
    def initialize(name, location = nil)
      @name = name.to_sym
      @url_map = Innate::URLMap.new
      self.location = location if location

      APP_LIST[@name] = self

      @options = self.class.options.sub(@name)
    end

    ##
    # Syncs the instance of the current application with Ramaze::AppMap.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    #
    def sync
      AppMap.map(location, self)
    end

    ##
    # Sets the location and syncs the application.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    #
    def location=(location)
      @location = location.to_str.freeze
      sync
    end

    ##
    # Allows the application to be called as a Rack middleware.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    # @param  [Hash] env The environment hash.
    #
    def call(env)
      to_app.call(env)
    end

    ##
    # Converts the application to a Rack compatible class.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    # @return [Rack::Cascade]
    #
    def to_app
      files = Ramaze::Files.new(*public_roots)
      app = Current.new(Route.new(url_map), Rewrite.new(url_map))
      Rack::Cascade.new([files, app])
    end

    ##
    # Maps an object to the given URI.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    # @param  [String] location The URI to map the object to.
    # @param  [Object] object The object (usually a controller) to map to the
    #  URI.
    #
    def map(location, object)
      url_map.map(location, object)
    end

    ##
    # Returns a URI to the given object.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    # @param  [Object] object An object for which to generate the URI.
    #
    def to(object)
      return unless mapped = url_map.to(object)
      [location, mapped].join('/').squeeze('/')
    end

    ##
    # Returns an array containing all the public directories for each root
    # directory.
    #
    # @author Michael Fellinger
    # @since  30-06-2009
    # @return [Array]
    #
    def public_roots
      roots, publics = [*options.roots], [*options.publics]
      roots.map{|root| publics.map{|public| ::File.join(root, public) }}.flatten
    end
  end # App
end # Ramaze
