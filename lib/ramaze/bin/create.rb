require 'fileutils'

module Ramaze
  #:nodoc:
  module Bin
    ##
    # Simple command that allows users to easily create a new application based
    # on the prototype that ships with Ramaze.
    #
    # Usage:
    #
    #    ramaze create blog
    #
    # @author Yorick Peterse
    # @since  21-07-2011
    #
    class Create
      # The description of this command as shown in the global help message.
      Description = 'Allows developers to easily create new Ramaze applications.'

      # The banner of this command.
      Banner = <<-TXT.strip
Allows developers to easily create new Ramaze applications based on the
prototype that ships with Ramaze.

Usage:
  ramaze create [NAME] [OPTIONS]

Example:
  ramaze create blog
      TXT

      ##
      # Creates a new instance of the command and sets the options for
      # OptionParser.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      #
      def initialize
        @options = {
          :force => false
        }

        @opts = OptionParser.new do |opt|
          opt.banner         = Banner
          opt.summary_indent = '  '

          opt.separator "\nOptions:\n"

          opt.on('-f', '--force', 'Overwrites existing directories') do
            @options[:force] = true
          end

          opt.on('-h', '--help', 'Shows this help message') do
            puts @opts
            exit
          end
        end
      end

      ##
      # Runs the command based on the specified command line arguments.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      # @param  [Array] argv Array containing all command line arguments.
      #
      def run(argv = [])
        @opts.parse!(argv)

        path  = argv.delete_at(0)
        proto = __DIR__('../../proto')

        abort 'You need to specify a name for your application' if path.nil?

        if File.directory?(path) and @options[:force] === false
          abort 'The specified application already exists, use -f to overwrite it'
        end

        if File.directory?(path) and @options[:force] === true
          FileUtils.rm_rf(path)
        end

        begin
          FileUtils.cp_r(proto, path)
          puts "The application has been generated and saved in #{path}"
        rescue
          abort 'The application could not be generated'
        end
      end
    end # Create
  end # Bin
end # Ramaze
