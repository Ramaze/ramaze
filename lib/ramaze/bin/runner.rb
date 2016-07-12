require 'optparse'
require 'pathname'

require __DIR__('create')

module Ramaze
  #:nodoc:
  module Bin
    ##
    # Module used for running a particular command based on the specified
    # command line arguments.
    #
    # Usage:
    #
    #    ramaze --help # Shows a help message
    #    ramaze -h     # Shows a help message as well
    #    ramaze -v     # Shows the version of Ramaze
    #
    #    ramaze [COMMAND] # Runs [COMMAND]
    #
    # @author Yorick Peterse
    # @since  21-07-2011
    #
    module Runner
      Commands = {
        :create  => Ramaze::Bin::Create,
      }

      Banner = <<-TXT.strip
Ramaze is a simple, light and modular open-source web application
framework written in Ruby.

Usage:
  ramaze [COMMAND] [OPTIONS]

Example:
  ramaze --help # this message
  ramaze create -h # help for the create command
  ramaze create blog # create a project named blog
  ramaze create blog -a mysql2 -d blog_dev -u bloguser -p dFLaWp3uts97pFwcdz7 # same, but with database
      TXT

      ##
      # Runs a particular command based on the specified array.
      #
      # @example
      #  Ramaze::Bin::Runner.run(ARGV)
      #  Ramaze::Bin::Runner.run(['start', '--help'])
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      # @param  [Array] argv An array containing command line arguments, set to
      #  ARGV by default.
      #
      def self.run(argv=ARGV)
        help = false
        op = OptionParser.new do |opt|
          opt.banner         = Banner
          opt.summary_indent = '  '

          opt.separator "\nCommands:\n  #{commands_info.join("\n  ")}"

          # Show all the common options
          opt.separator "\nOptions:\n"

          # Show the version of Ramaze
          opt.on('-v', '--version', 'Shows the version of Ramaze') do
            puts Ramaze::VERSION
            exit
          end

          # Show the help message
          opt.on('-h', '--help', 'Shows this help message') do
            help = true
          end
        end

        op.order!(argv)

        # Show a help message if no command has been specified
        if !argv[0]
          puts op.to_s
          exit
        end

        cmd = argv.delete_at(0).to_sym

        if Commands.key?(cmd)
          cmd = Commands[cmd].new
          cmd.run(argv)
        else
          if help
            puts op
            exit 
          else
            abort 'The specified command is invalid'
          end
        end
      end

      ##
      # Generates an array of "rows" where each row contains the name and
      # description of a command. The descriptions of all commands are aligned
      # based on the length of the longest command name.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      # @return [Array]
      #
      def self.commands_info
        cmds    = []
        longest = Commands.map { |name, klass| name.to_s }.sort[0].size

        Commands.each do |name, klass|
          name = name.to_s
          desc = ''

          # Try to extract the command description
          if klass.respond_to?(:const_defined?) \
          and klass.const_defined?(:Description)
            desc = klass.const_get(:Description)
          end

          # Align the description based on the length of the name
          while name.size <= longest do
            name += ' '
          end

          cmds.push(["#{name}    #{desc}"])
        end

        return cmds
      end
    end # Runner
  end # Bin
end # Ramaze
