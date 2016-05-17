require 'fileutils'
require 'sequel'

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
    # @author Michael J. Welch, Ph.D.
    # @since  17-05-2016
    #
    class Create
      Description = 'Creates a new Ramaze application'

      Banner = <<-TXT.strip
Allows developers to easily create new Ramaze applications based on the
prototype that ships with Ramaze.

Usage:
  ramaze create [NAME] [OPTIONS]

Example:
  ramaze create --help # this message
  ramaze create blog # create a project named blog
  ramaze create blog -a mysql2 -d blog_dev -u bloguser -p dFLaWp3uts97pFwcdz7 # same, but with database
      TXT

      ##
      # Creates a new instance of the command and sets the options for
      # OptionParser.
      #
      # @author Yorick Peterse
      # @since  21-07-2011
      #
      # @author Michael J. Welch, Ph.D.
      # @since  17-05-2016
      #
      def initialize
        @options = {
          :force => false,
          :adapter => nil,
          :server => 'localhost',
          :dbname => 'your_dbname',
          :username => 'your_username',
          :password => 'your_password'
        }

        @opts = OptionParser.new do |opt|
          opt.banner         = Banner
          opt.summary_indent = '  '

          opt.separator "\nOptions:\n"

          opt.on('-a', '--adapter adapter', 'Specifies the database adapter name [no default]') do |adapter|
            @options[:adapter] = adapter
          end

          opt.on('-s', '--server server', 'Specifies the database server(host) name [default: localhost]') do |server|
            @options[:server] = server
          end

          opt.on('-d', '--dbname dbname', 'Specifies the database dbname [default: your_dbname]') do |dbname|
            @options[:dbname] = dbname
          end

          opt.on('-u', '--username username', 'Specifies the database username [default: your_username]') do |username|
            @options[:username] = username
          end

          opt.on('-p', '--password password', 'Specifies the database password [default: your_password]') do |password|
            @options[:password] = password
          end

          opt.on('-f', '--force', 'Overwrites existing directories') do
            @options[:force] = true
          end

          opt.on('-h', '--help', 'Shows this help message') do
            puts @opts.to_s
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
        abort 'You need to specify a name for your application' if path.nil?

        proto = __DIR__('../../proto')
        proto_adapter = if @options[:adapter] then "#{proto}-#{@options[:adapter]}" else nil end
        abort "The #{@options[:adapter]} adapter is not supported--See the documentation" if proto_adapter && Dir[proto_adapter].empty?

        if File.directory?(path) and @options[:force] === false
          abort 'The specified application already exists, use -f to overwrite it'
        end

        if File.directory?(path) and @options[:force] === true
          FileUtils.rm_rf(path)
        end

        begin
          FileUtils.cp_r(proto, path)

          if proto_adapter
            # copy whatever is in the proto-adapter directory
            FileUtils.cp_r(Dir.glob("#{proto_adapter}/**"), path)

            # update the database.yml file in the new project
            yml = nil
            File::open("#{path}/database.yml",'r') { |f| yml = f.read }
            [:adapter, :server, :dbname, :username, :password].each do |opt|
              yml.gsub!("{#{opt.to_s}}",@options[opt])
            end
            File::open("#{path}/database.yml",'w') { |f| yml = f.write(yml) }
          end

          puts "The application has been generated and saved in #{path}"
        rescue => e
        puts e.backtrace[0..5]
          abort "#{e}\nThe application could not be generated"
        end
      end
    end # Create
  end # Bin
end # Ramaze
