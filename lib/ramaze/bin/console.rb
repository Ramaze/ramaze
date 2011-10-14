require 'irb'
require 'irb/completion'

module Ramaze
  #:nodoc:
  module Bin
    ##
    # Allows the user to enter an IRB like session that takes advantage of
    # everything provided by Ramaze.
    #
    # Usage:
    #
    #    ramaze console
    #    ramaze console /path/to/app/start.rb
    #
    # @author Yorick Peterse
    # @since  21-07-2011
    #
    class Console
      # String containing the description of this command.
      Description = 'Starts an IRB session with Ramaze loaded into the session'

      # The banner that is displayed when the -h or --help option is specified.
      Banner = <<-TXT.strip
Starts an IRB session and loads Ramaze into the session. All specified Rack
options are ignored and environment variables are passed to IRB.

Usage:
  ramaze console [DIR] [OPTIONS]

Example:
  ramaze console
  ramaze console /home/foobar/ramaze/start.rb
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
        @options.parse!(argv)

        start_file = argv.delete_at(0)
        start_file = File.join(Dir.pwd, 'start.rb') if start_file.nil?

        if File.directory?(start_file)
          start_file = File.join(start_file, 'start.rb')
        end

        if !File.exist?(start_file)
          abort "The file #{start_file} does not exist"
        end

        start_file             = Pathname.new(start_file).realpath.to_s
        Ramaze.options.started = true

        require(start_file)

        IRB.start
        puts 'Ramazement has ended, go in peace.'
      end
    end # Console
  end # Bin
end # Ramaze
