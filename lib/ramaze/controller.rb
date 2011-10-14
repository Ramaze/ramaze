#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  ##
  # Ramaze::Controller is the base controller of all controllers when developing
  # applications in Ramaze. It acts as a nice wrapper around Innate::Node and
  # allows for a more traditional MVC approach.
  #
  # @example An example controller
  #  class Posts < Ramaze::Controller
  #    map '/posts'
  #
  #    def index
  #
  #    end
  #  end
  #
  # @author Michael Fellinger
  # @since  04-01-2009
  #
  class Controller
    include Innate::Traited
    include Innate::Node

    # we are no mapped node
    Innate::Node::NODE_LIST.delete(self)

    # call our setup method one startup
    Ramaze.options.setup << self

    CONTROLLER_LIST = Set.new

    trait :app => :pristine
    trait :skip_controller_map => false

    ##
    # Hash containing the names of two common controller names and the URIs they
    # should be mapped to.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    #
    IRREGULAR_MAPPING = {
      'Controller'     => nil,
      'MainController' => '/'
    }

    ##
    # Modifies the extending class so that it's properly set up to be used as a
    # controller.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    # @param  [Class] into The class that extended Ramaze::Controller (or a sub
    #  class).
    #
    def self.inherited(into)
      Innate::Node.included(into)
      into.helper(:layout)
      CONTROLLER_LIST << into
      into.trait :skip_node_map => true
    end

    ##
    # Sets all the controllers up and loads a default controller in case no
    # custom ones have been specified.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    #
    def self.setup
      case CONTROLLER_LIST.size
      when 0
        require 'ramaze/controller/default'
      when 1
        controller = CONTROLLER_LIST.to_a.first

        begin
          controller.mapping
        rescue
          controller.map '/'
        end

        controller.setup_procedure
      else
        CONTROLLER_LIST.each do |controller|
          controller.setup_procedure
        end
      end
    end

    ##
    # Method that's used to setup each controller, called by
    # Ramaze::Controller.setup.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    #
    def self.setup_procedure
      unless ancestral_trait[:provide_set]
        engine(:etanni)
        trait(:provide_set => false)
      end

      map(generate_mapping(name)) unless trait[:skip_controller_map]
    end

    ##
    # Sets the view engine to use for pages with a content type of text/html.
    #
    # @example
    #  class Posts < Ramaze::Controller
    #    engine :etanni
    #  end
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    # @param  [#to_sym] name The name of the view engine to use.
    #
    def self.engine(name)
      provide(:html, name.to_sym)
    end

    ##
    # Returns the URI a controller is mapped to.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    # @return [String]
    #
    def self.mapping
      Ramaze.to(self)
    end

    ##
    # Generates a URI for the full namespace of a class. If a class is named
    # A::B::C the URI would be /a/b/c.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    # @param  [String] klass_name The name of the class for which to generate
    #  the mapping, defaults to the current class.
    # @return [String]
    #
    def self.generate_mapping(klass_name = self.name)
      chunks = klass_name.to_s.split(/::/)
      return if chunks.empty?

      last = chunks.last
      return IRREGULAR_MAPPING[last] if IRREGULAR_MAPPING.key?(last)

      last.sub!(/Controller$/, '')
      '/' << chunks.map{|chunk| chunk.snake_case }.join('/')
    end

    ##
    # Maps the current class to the specified location.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    # @param  [String] location The URI to map the controller to.
    # @param  [String] app_name The name of the application the controller
    #  belongs to.
    #
    def self.map(location, app_name = nil)
      if app_name
        trait :app => app_name
      else
        app_name = ancestral_trait[:app]
      end

      trait :skip_controller_map => true

      App.find_or_create(app_name).map(location, self)
    end

    ##
    # Returns the application to which the controller belongs to.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    # @return [Ramaze::App]
    #
    def self.app
      App[ancestral_trait[:app]]
    end

    ##
    # Returns all the options for the application the controller belongs to.
    #
    # @author Michael Fellinger
    # @since  04-01-2009
    # @return [Innate::Options]
    #
    def self.options
      return unless app = self.app
      app.options
    end
  end # Controller
end # Ramaze
