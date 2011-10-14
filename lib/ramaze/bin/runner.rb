require 'optparse'
require 'pathname'

require __DIR__('helper')
require __DIR__('start')
require __DIR__('restart')
require __DIR__('stop')
require __DIR__('create')
require __DIR__('status')
require __DIR__('console')

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
      # Hash containing all the available commands, their names and their
      # classes.
      Commands = {
        :start   => Ramaze::Bin::Start,
        :stop    => Ramaze::Bin::Stop,
        :restart => Ramaze::Bin::Restart,
        :status  => Ramaze::Bin::Status,
        :create  => Ramaze::Bin::Create,
        :console => Ramaze::Bin::Console,
      }

      # String containing the banner of the main command.
      Banner = <<-TXT.strip
Ramaze is a simple, light and modular open-source web application
framework written in Ruby.

Usage:
  ramaze [COMMAND] [OPTIONS]

Example:
  ramaze create blog
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

          opt.on('-h', '--help', 'Shows this help message') do
            puts op
            exit
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
          abort 'The specified command is invalid'
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
