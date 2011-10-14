module Ramaze
  #:nodoc:
  module Bin
    ##
    # Restarts an application based on a specified directory/rackup file and
    # PID. The PID is used to kill the process, the Rackup file is used to start
    # the process again after it has been killed.
    #
    # Usage:
    #
    #    ramaze restart
    #    ramaze restart /home/foobar/projects/ramaze/ \
    #    -P /home/foobar/projects/ramaze/ramaze.pid
    #
    # @author Yorick Peterse
    # @since  21-07-2011
    #
    class Restart
      # The description of this command, displayed in the global help message.
      Description = 'Restarts an application'

      # The banner, displayed when the -h or --help option is specified.
      Banner = <<-TXT.strip
Restarts an active Ramaze application.

Usage:
  ramaze restart [RACKUP] [OPTIONS]

Example:
  ramaze restart config.ru -P ramaze.pid
      TXT

      ##
      # Creates a new instance of the command and sets all the options.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      #
      def initialize
        @options = OptionParser.new do |opt|
          opt.banner         = Banner
          opt.summary_indent = '  '

          opt.separator "\nOptions:\n"

          opt.on('-h', '--help', 'Shows this help message') do
            puts @options
            exit
          end

          opt.on(
            '-P',
            '--pid FILE',
            'Uses the PID to kill the application'
          ) do |pid|
            @pid = pid
          end
        end
      end

      ##
      # Runs the command based on the specified command line arguments.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      # @param  [Array] argv An array containing all command line arguments.
      #
      def run(argv = [])
        @options.parse!(argv)

        @rackup = argv.delete_at(0)
        @rackup = File.join(Dir.pwd, 'config.ru') if @rackup.nil?

        if File.directory?(@rackup)
          @rackup = File.join(@rackup, 'config.ru')
        end

        if !File.exist?(@rackup)
          abort "The Rackup file #{@rackup} does not exist"
        end

        stop   = Ramaze::Bin::Runner::Commands[:stop].new
        start  = Ramaze::Bin::Runner::Commands[:start].new
        params = [@rackup]

        unless @pid.nil?
          params.push("-P #{@pid}")
        end

        stop.run([@pid])
        start.run(params)
      end
    end # Restart
  end # Bin
end # Ramaze
