module Ramaze
  ##
  # Convenient setup and activation of gems from different sources and specific
  # versions.  It's almost like Kernel#gem but also installs automatically if a
  # gem is missing.
  #
  # @example
  #  Ramaze.setup :verbose => true do
  #    # gem and specific version
  #    gem 'makura', '>=2009.01'
  #
  #    # gem and name for require
  #    gem 'aws-s3', :lib => 'aws/s3'
  #
  #    # gem with specific version from rubyforge (default)
  #    gem 'json', :version => '=1.1.3', :source => rubyforge
  #  end
  #
  # @author manveru
  # @since  19-05-2009
  # @see    GemSetup#initialize
  #
  def self.setup(options = {:verbose => true}, &block)
    GemSetup.new(options, &block)
  end

  ##
  # Class responsible for installing and loading all the gems.
  #
  # @author Michael Fellinger (manveru)
  # @since  19-05-2009
  #
  class GemSetup
    ##
    # Creates a new instance of the class and saves the parameters that were set.
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    # @param  [Hash] options Hash containing various options to pass to the
    #  GemSetup class.
    # @option options :verbose When set to true Ramaze will log
    #  various actions such as messages about the installation process.
    # @yield block
    #
    def initialize(options = {}, &block)
      @gems = []
      @options = options.dup
      @verbose = @options.delete(:verbose)

      run(&block)
    end

    ##
    # Executes the data inside the block, loading all the gems and optionally
    # installing them.
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    # @param  [Proc] block A block containing all the calls to gem().
    #
    def run(&block)
      return unless block_given?
      instance_eval(&block)
      setup
    end

    ##
    # Adds the given gem to the list of required gems.
    #
    # @example
    #  gem('json', '>=1.5.1')
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    # @param  [String] name The name of the gem to load.
    # @param  [String] version The version of the gem.
    # @param  [Hash] options Additional options to use when loading the gem.
    # @option options :lib The name to load the gem as.
    #
    def gem(name, version = nil, options = {})
      if version.respond_to?(:merge!)
        options = version
      else
        options[:version] = version
      end

      @gems << [name, options]
    end

    ##
    # Tries to install all the gems.
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    #
    def setup
      require 'rubygems'
      require 'rubygems/dependency_installer'

      @gems.each do |name, options|
        setup_gem(name, options)
      end
    end

    ##
    # First try to activate, install and try to activate again if activation
    # fails the first time.
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    # @param  [String] name The name of the gem to activate.
    # @param  [Hash] options The options from GemSetup#initialize.
    #
    def setup_gem(name, options)
      version  = [options[:version]].compact
      lib_name = options[:lib] || name

      log "Activating gem #{name}"

      activate(name, lib_name, *version)
    # Gem not installed yet
    rescue Gem::LoadError
      install_gem(name, options)
      activate(name, lib_name, *version)
    end

    ##
    # Tell Rubygems to install a gem.
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    # @param  [String] name The name of the gem to activate.
    # @param  [Hash] options The options to use for installing the gem.
    #
    def install_gem(name, options)
      installer = Gem::DependencyInstaller.new(options)

      temp_argv(options[:extconf]) do
        log "Installing gem #{name}"
        installer.install(name, options[:version])
      end
    end

    ##
    # Prepare ARGV for rubygems installer
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    # @param  [String] extconf
    #
    def temp_argv(extconf)
      if extconf ||= @options[:extconf]
        old_argv = ARGV.clone
        ARGV.replace(extconf.split(' '))
      end

      yield

    ensure
      ARGV.replace(old_argv) if extconf
    end

    private

    ##
    # Activates a gem and requires it.
    #
    # @author Yorick Peterse
    # @author Lee Jarvis
    # @since  20-08-2011
    # @param  [String] name The name of the gem to activate.
    # @param  [String] lib_name The name of the gem as it should be required.
    # @param  [Array] requirements An array with additional requirements.
    #
    def activate(name, lib_name, *requirements)
      if Gem::Specification.respond_to?(:find_by_name)
        Gem::Specification.find_by_name(name, *requirements).activate
      else
        Gem.activate(name, *requirements)
      end

      require(lib_name)
    end

    ##
    # Writes the message to the logger.
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    # @param  [String] msg The message to write to the logger.
    #
    def log(msg)
      return unless @verbose

      if defined?(Log)
        Log.info(msg)
      else
        puts(msg)
      end
    end

    ##
    # Installs a gem from Rubyforge.
    #
    # @author Michael Fellinger (manveru)
    # @since  19-05-2009
    #
    def rubyforge; 'http://gems.rubyforge.org/' end
  end # GemSetup
end # Ramaze
