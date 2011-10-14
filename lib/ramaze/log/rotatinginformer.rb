module Ramaze
  module Logger
    ##
    # A logger that rotates log files based on the current date. Log files are
    # named after the date on which they were created. If the date changes a new
    # log file is used.
    #
    # In order to use this logger you'll have to specify a base directory for
    # all log files. This directory will not be created for you so make sure it
    # exists. Loading the class can be done as following:
    #
    #     logger = Ramaze::Logger::RotatingInformer.new('./log')
    #
    # This creates a new instance that uses the directory ``./log`` for all it's
    # log files.
    #
    # The default log format is ``%Y-%m-%d.log``. If you want to change this you
    # can specify an alternative format (including the extension) as the
    # secondary parameter of the ``.new()`` method:
    #
    #     logger = Ramaze::Logger::RotatingInformer.new('./log', '%d-%m-%Y.log')
    #
    # In this case the instance will use the date format ``dd-mm-yyyy`` along
    # with the ``.log`` extension.
    #
    # Besides the date format you can also customize the timestamp format as
    # well as the format of each logged messages. Both these are set in a trait.
    # The timestamp format is located in the trait ``:timestamp`` while the
    # message format is stored in the ``:format`` trait. These can be set as
    # following:
    #
    #     logger = Ramaze::Logger::RotatingInformer.new('./log')
    #
    #     logger.trait[:timestamp] = '...'
    #     logger.trait[:format]    = '...'
    #
    # When setting the ``:format`` trait you can use 3 tags that will be
    # replaced by their corresponding values. These are the following tags:
    #
    # * ``%time``: will be replaced by the current time.
    # * ``%prefix``: the log level such as "ERROR" or "INFO".
    # * ``%text``: the actual log message.
    #
    class RotatingInformer
      include Innate::Traited
      include Logging

      attr_accessor :time_format, :log_levels
      attr_reader :base_dir

      # parameter for Time.now.strftime
      trait :timestamp => "%Y-%m-%d %H:%M:%S"

      # This is how the final output is arranged.
      trait :format => "[%time] %prefix  %text"

      ##
      # Create a new instance of RotatingInformer.
      #
      # base_dir is the directory where all log files will be stored
      #
      # time_format is the time format used to name the log files. Possible
      # formats are identical to those accepted by Time.strftime
      #
      # log_levelse is an array describing what kind of messages that the log
      # receives. The array may contain any or all of the symbols :debug,
      # :error, :info and/or :warn
      #
      # @example
      #   # Creates logs in directory called logs. The generated filenames
      #   # will be in the form YYYY-MM-DD.log
      #   RotatingInformer.new('logs')
      #
      #   # Creates logs in directory called logs. The generated filenames
      #   # will be in the form YYYY-MM.txt
      #   RotatingInformer.new('logs', '%Y-%m.txt')
      #
      #   # Creates logs in directory called logs. The generated filenames
      #   # will be in the form YYYY-MM.txt.
      #   # Only errors will be logged to the files.
      #   RotatingInformer.new('logs', '%Y-%m.txt', [:error])
      #
      # @param [String] base_dir The base directory for all the log files.
      # @param [String] time_format The time format for all log files.
      # @param [Array] log_levels Array containing the type of messages to log.
      #
      def initialize(base_dir, time_format = '%Y-%m-%d.log',
      log_levels = [:debug, :error, :info, :warn])
        # Verify and set base directory
        send :base_dir=, base_dir, true

        @time_format = time_format
        @log_levels  = log_levels

        # Keep track of log shutdown (to prevent StackErrors due to recursion)
        @in_shutdown = false
      end

      ##
      # Set the base directory for log files
      #
      # If this method is called with the raise_exception parameter set to true
      # the method will raise an exception if the specified directory does not
      # exist or is unwritable.
      #
      # If raise_exception is set to false, the method will just silently fail
      # if the specified directory does not exist or is unwritable.
      #
      # @param [String] directory The base directory specified by the developer.
      # @param [Bool] raise_exception Boolean that indicates if an exception
      #  should be raised if the base directory doesn't exist.
      #
      def base_dir=(directory, raise_exception = false)
        # Expand directory path
        base_dir = File.expand_path(directory)
        # Verify that directory path exists
        if File.exist?(base_dir)
          # Verify that directory path is a directory
          if File.directory?(base_dir)
            # Verify that directory path is writable
            if File.writable?(base_dir)
              @base_dir = base_dir
            else
              raise Exception.new("#{base_dir} is not writable") if raise_exception
            end
          else
            raise Exception.new("#{base_dir} is not a directory") if raise_exception
          end
        else
          raise Exception.new("#{base_dir} does not exist.") if raise_exception
        end
      end

      ##
      # Close the file we log to if it isn't closed already.
      #
      def shutdown
        if @out.respond_to?(:close)
          unless @in_shutdown
            @in_shutdown = true
            Log.debug("close, #{@out.inspect}")
            @in_shutdown = false
          end
          @out.close
        end
      end

      ##
      # Integration to Logging.
      #
      # @param [String] tag The type of message we're logging.
      # @param [Array] messages An array of messages to log.
      #
      def log(tag, *messages)
        return unless @log_levels.include?(tag)

        # Update current log
        update_current_log

        messages.flatten!

        prefix = tag.to_s.upcase.ljust(5)

        messages.each do |message|
          @out.puts(log_interpolate(prefix, message))
        end

        @out.flush if @out.respond_to?(:flush)
      end

      ##
      # Takes the prefix (tag), text and timestamp and applies it to
      # the :format trait.
      #
      # @param [String] prefix
      # @param [String] text
      # @param [Integer] time
      #
      def log_interpolate(prefix, text, time = timestamp)
        message = class_trait[:format].dup

        vars = { '%time' => time, '%prefix' => prefix, '%text' => text }
        vars.each{|from, to| message.gsub!(from, to) }

        message
      end

      ##
      # This uses timestamp trait or a date in the format of
      # ``%Y-%m-%d %H:%M:%S``
      #
      # @return [String]
      #
      def timestamp
        mask = class_trait[:timestamp]
        Time.now.strftime(mask || "%Y-%m-%d %H:%M:%S")
      end

      ##
      # Is ``@out`` closed?
      #
      # @return [TrueClass|FalseClass]
      #
      def closed?
        @out.respond_to?(:closed?) && @out.closed?
      end

      ##
      # Method that is called by Rack::CommonLogger when logging data to a file.
      #
      # @author Yorick Peterse
      # @param  [String] message The data that has to be logged.
      #
      def write(message)
        log(:info, message)
      end

      private

      ##
      # Checks whether current filename is still valid. If not, update the
      # current log to point at the new filename.
      #
      def update_current_log
        out = File.join(@base_dir, Time.now.strftime(@time_format))

        if @out.nil? || @out.path != out
          # Close old log if necessary
          shutdown unless @out.nil? || closed?

          # Start new log
          @out = File.open(out, 'ab+')
        end
      end
    end # RotatingInformer
  end # Log
end # Ramaze
