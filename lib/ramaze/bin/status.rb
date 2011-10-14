module Ramaze
  #:nodoc:
  module Bin
    ##
    # The status command can be used to show the details, such as the PID and
    # the CPU usage, of a running Ramaze application.
    #
    # Usage:
    #
    #    ramaze status
    #    ramaze status /home/projects/ramaze/ramaze.pid
    #
    # @author Yorick Peterse
    # @author TJ Vanderpoel
    # @since  21-07-2011
    #
    class Status
      include Ramaze::Bin::Helper

      # Description of this command, displayed in the glboal help message.
      Description = 'Shows the status of a running Ramaze application'

      # The banner of this command, displayed when the -h or --help option is
      # specified.
      Banner = <<-TXT.strip
Shows the status of a running Ramaze application. If a PID is specified this
command will use that PID, otherwise it will try to look for a PID in the
current directory.

Usage:
  ramaze status [PID] [OPTIONS]

Example:
  ramaze status blog/blog.pid
      TXT

      # String containing the message that's used to display all statistics
      Statistics = <<-TXT.strip
Ramaze is running!
Name: %s
Command Line: %s
Virtual Size: %s
Started: %s
Exec Path: %s
Status: %s
      TXT

      ##
      # Creates a new instance of the command and sets all the option parser
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
      # Runs the command based on the given command line arguments.
      #
      # @author Yorick Peterse
      # @author TJ Vanderpoel
      # @since  21-07-2011
      # @param  [Array] argv Array containing all teh command line arguments.
      #
      def run(argv = [])
        @options.parse!(argv)

        pid_path = argv.delete_at(0)
        dirname  = Pathname.new('.').realpath.basename.to_s
        pid_path = File.join(Dir.pwd, dirname + '.pid') if pid_path.nil?

        # Is it a directory?
        if File.directory?(pid_path)
          pid_path = File.join(pid_path, File.basename(pid_path) + '.pid')
        end

        pid_path = Pathname.new(pid_path).expand_path.to_s

        if !File.exist?(pid_path)
          abort "The PID #{pid_path} does not exist"
        end

        # Is the app running?
        unless is_running?(pid_path)
          abort "The Ramaze application for #{pid_path} isn't running"
        end

        pid = File.read(pid_path).to_i

        # Gather various statistics about the process
        if is_windows?
          wmi       = WIN32OLE.connect("winmgmts://")
          ours      = []
          processes = wmi.ExecQuery(
            "select * from win32_process where ProcessId = #{pid}"
          )

          processes.each do |p|
            ours << [
              p.Name,
              p.CommandLine,
              p.VirtualSize,
              p.CreationDate,
              p.ExecutablePath,
              p.Status
            ]
          end

          puts Statistics % ours.first
        # Unix like systems
        else
          if File.directory?(proc_dir = Pathname.new('/proc'))
            proc_dir = proc_dir.join(pid.to_s)
            # If we have a "stat" file, we'll assume linux and get as much info
            # as we can
            if File.file?(stat_file = proc_dir.join("stat"))
              stats = File.read(stat_file).split

              puts Statistics % [
                nil,
                File.read(proc_dir.join("cmdline")).split("\000").join(" "),
                "%s k" % (stats[22].to_f / 1024),
                File.mtime(proc_dir),
                File.readlink(proc_dir.join("exe")),
                stats[2]
              ]
            end
          # /proc does not exist, use "ps"
          else
            begin
              puts %x{ps l #{pid}}
            rescue
              puts "Sadly no more information is available"
            end
          end
        end
      end
    end # Status
  end # Bin
end # Ramaze
