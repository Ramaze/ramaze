module Ramaze
  #:nodoc:
  module Bin
    ##
    # Stops a running instance of Ramaze by killing it's process. The PID of
    # this process can be supplied via the command line. If no PID is given this
    # command tries to find it in the current directory. If the latter is the
    # case this command tries to find a file of which the name matches the name
    # of the current directory.
    #
    # Usage:
    #
    #    ramaze stop
    #    ramaze stop /home/foobar/projects/ramaze/ramaze.pid
    #
    # @author Yorick Peterse
    # @author TJ Vanderpoel
    # @since  21-07-2011
    #
    class Stop
      include Ramaze::Bin::Helper

      # The description of this command, shown when the global help menu is
      # displayed.
      Description = 'Stops a running instance of Ramaze'

      # The banner of this command.
      Banner = <<-TXT.strip
Stops a running instance of Ramaze by killing it's process using a PID. If no
PID is given this command tries to look for it in the current directory.

Usage:
  ramaze stop [PID] [OPTIONS]

Example:
  ramaze stop /home/foobar/projects/ramaze/ramaze.pid
      TXT

      ##
      # Creates a new instance of the command and sets all the OptionParser
      # options.
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
      # Runs the command based on the specified command line arguments.
      #
      # @author Yorick Peterse
      # @author TJ Vanderpoel
      # @since  21-07-2011
      # @param  [Array] argv Array containing all the command line arguments.
      #
      def run(argv = [])
        @options.parse!(argv)

        pid_path = argv.delete_at(0)
        dirname  = Pathname.new('.').expand_path.basename.to_s
        pid_path = File.join(Dir.pwd, dirname + '.pid') if pid_path.nil?

        if File.directory?(pid_path)
          pid_path = File.join(pid_path, File.basename(pid_path) + '.pid')
        end

        pid_path = Pathname.new(pid_path).expand_path.to_s

        if !File.exist?(pid_path)
          abort "The PID #{pid_path} does not exist"
        end

        pid = File.read(pid_path).to_i
        puts 'Stopping the process using SIGINT'

        begin
          Process.kill('INT', pid)
        rescue => e
          abort "Failed to kill the process: #{e.message}"
        end

        sleep(2)

        # Verify that the process has been killed
        if is_running?(pid_path)
          $stderr.puts "The process is still running, let's kill it with -9"

          begin
            Process.kill(9, pid)
          rescue => e
            abort "Failed to kill the process: #{e.message}"
          end
        end

        File.unlink(pid_path) if File.exist?(pid_path)
        puts 'Ramazement has ended, go in peace.'
      end
    end # Stop
  end # Bin
end # Ramaze
