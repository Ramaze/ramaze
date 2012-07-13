module Ramaze
  ##
  # Class that makes it possible to easily use multiple public directories in
  # your Ramaze application.
  #
  # @author Michael Fellinger
  # @since  14-03-2009
  #
  class Files
    ##
    # Creates a new instance of the class, stores the given root directories and
    # syncs the changes with Rack::Cascade.
    #
    # @author Michael Fellinger
    # @since  14-03-2009
    # @param  [Array] *roots A set of root directories that contain a number of
    #  public directories.
    #
    def initialize(*roots)
      @roots = roots.flatten.map{|root| File.expand_path(root.to_s) }
      sync
    end

    ##
    # Allows this class to be called as a Rack middleware.
    #
    # @author Michael Fellinger
    # @since  14-03-2009
    # @param  [Hash] env Hash containing all the environment details.
    #
    def call(env)
      @cascade.call(env)
    end

    ##
    # Adds a new path to the list of root directories.
    #
    # @author Michael Fellinger
    # @since  14-03-2009
    # @param  [String] path The path to add to the existing root directories.
    #
    def <<(path)
      @roots << File.expand_path(path.to_s)
      @roots.uniq!
      sync
    end

    ##
    # Syncs the class with Rack::Cascade.
    #
    # @author Michael Fellinger
    # @since  14-03-2009
    #
    def sync
      file_apps = @roots.map{|root| RackFileWrapper.new(root) }
      @cascade = Rack::Cascade.new(file_apps)
    end
  end # Files
end # Ramaze
