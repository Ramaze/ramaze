module Ramaze
  #:nodoc:
  module Bin
    ##
    # The start command is used to start a Ramaze application. The ramaze start
    # command optionally takes a directory or path to a file. If it's a
    # directory this command will look for a Rackup file in that directory,
    # otherwise it assumes the specified file is a Rackup file.
    #
    # Usage:
    #
    #    ramaze start
    #    ramaze start /home/foobar/projects/blog/config.ru
    #    ramaze start /home/foobar/projects/blog
    #
    # @author Yorick Peterse
    # @since  21-07-2011
    #
    class Start
      include Ramaze::Bin::Helper

      # The description of this command, displayed when the global help menu is
      # invoked.
      Description = 'Starts an instance of an application'

      # The banner of this command, displayed when it's invoked with the -h or
      # --help option.
      Banner = <<-TXT.strip
Starts an instance of an application using the settings
specified in a Rackup file in the current directory.

Usage:
  ramaze start [RACKUP CONFIG] [OPTIONS]

Example:
  ramaze start --help
      TXT

      ##
      # Creates a new instance of the command and prepares OptionParser.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      #
      def initialize
        @ruby_options = {}
        @rack_options = {}
        @options      = OptionParser.new do |opt|
          opt.banner         = Banner
          opt.summary_indent = '  '

          # Sets all Ruby options
          opt.separator "\nRuby Options:\n"

          opt.on('-e', '--eval LINE', 'Evaluates a line of code') do |code|
            @ruby_options['-e'] = code
          end

          opt.on('-d', '--debug', 'Set debugging flags (set $DEBUG to true)') do
            @ruby_options['-d'] = nil
          end

          opt.on('-w', '--warn', 'Turns warnings on for the script') do
            @ruby_options['-w'] = nil
          end

          opt.on('-I', '--include PATH', 'specifies the $LOAD_PATH') do |path|
            @ruby_options['-I'] = path
          end

          opt.on(
            '-r',
            '--require LIBRARY',
            'requires the library before starting'
          ) do |library|
            @ruby_options['-r'] = library
          end

          # Set all Rack options
          opt.separator "\nRack Options:\n"

          opt.on(
            '-s',
            '--server SERVER',
            'Serve the application using the given server'
          ) do |server|
            @rack_options['-s'] = server
          end

          opt.on(
            '-o',
            '--host HOST',
            'Listens on the given host (0.0.0.0 by default)'
          ) do |host|
            @rack_options['-o'] = host
          end

          opt.on(
            '-p',
            '--port PORT',
            'Uses the given port, set to 9292 by default'
          ) do |port|
            @rack_options['-p'] = port
          end

          opt.on(
            '-O',
            '--option NAME[=VALUE]',
            'Passes the given option and it\'s value to the server'
          ) do |name|
            @rack_options['-O'] = name
          end

          opt.on(
            '-E',
            '--env ENVIRONMENT',
            'Uses the specified environment, set to development by default'
          ) do |env|
            @rack_options['-E'] = env
          end

          opt.on('-D', '--daemonize', 'Runs as a daemon in the background') do
            @rack_options['-D'] = nil
          end

          opt.on(
            '-P',
            '--pid FILE',
            'File to store the PID in, defaults to rack.pid'
          ) do |pid|
            @rack_options['-P'] = pid
          end

          # Set all common options
          opt.separator "\nOptions\n"

          opt.on('-h', '--help', 'Shows this help message') do
            puts @options
            exit
          end
        end
      end

      ##
      # Runs the command based on the given command line arguments.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      # @param  [Array] argv An array of command line arguments.
      #
      def run(argv = [])
        begin
          @options.parse!(argv)
        rescue => e
          warn "Error: #{e.message}"
          abort @options.to_s
        end

        # Remove all trailing/leading whitespace from the options
        @rack_options.each do |k, v|
          @rack_options[k] = v.strip if v.respond_to?(:strip)
        end

        @ruby_options.each do |k, v|
          @ruby_options[k] = v.strip if v.respond_to?(:strip)
        end

        rackup_config = argv.delete_at(0)
        rackup_config = File.join(Dir.pwd, 'config.ru') if rackup_config.nil?

        # Check if the config is a directory or file
        if File.directory?(rackup_config)
          rackup_config = File.join(rackup_config, 'config.ru')
        end

        if !File.exist?(rackup_config)
          abort "The Rackup config #{rackup_config} does not exist"
        end

        # Set the default port and server to use.
        if !@rack_options['-p']
          @rack_options['-p'] = 7000
        end

        # Set the default server to use
        if !@rack_options['-s']
          @rack_options['-s'] = Ramaze.options.adapter.handler.to_s
        end

        # If a PID is supplied we should first check to see if Ramaze isn't
        # already running.
        if @rack_options.key?('-P') and is_running?(@rack_options['-P'])
          abort 'This application is already running'
        end

        params = []

        @ruby_options.merge(@rack_options).each do |opt, value|
          params.push("#{opt}#{value}")
        end

        exec('ruby', rackup_path, rackup_config, *params)
      end
    end # Start
  end # Bin
end # Ramaze
