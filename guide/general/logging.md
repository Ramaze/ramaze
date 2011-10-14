# Logging

Similar to the caching system Ramaze makes it easy to log information using a
unified API, whether you're logging to a file, using Growl or something else.
Ramaze itself only uses a single logger which logs to STDOUT by default. This
logger is stored in ``Ramaze::Log``. While you can just use this particular
logger it's recommended to create your own ones if you need to log specific
types of data (such as API calls).

Creating a custom logger works just like initializing a regular class. Say you
want to rotate your log files based on the current date, in that case
{Ramaze::Logger::RotatingInformer} should be used. To use this logger you'd
simply do the following:

    logger = Ramaze::Logger::RotatingInformer.new('./log')

This creates a new instance of the logger and tells it to store it's log files
in the ``./log`` directory. Each log file's name is the date on which it was
created in the format of ``yyyy-mm-dd``.

Once a logger has been created you can use the following logging methods:

* warn: logs a warning message.
* debug: logs a debugging message such as "Connected to the database".
* error: logs an error message, useful for logging validation errors and the
  like.
* info: logging method for generic log messages that don't fit into a specific
  category.

You can call these methods on the instance of a logger just like any other
method:

    logger.info 'Logging data sure is easy to do!'

## Creating Custom Loggers

Ramaze provides an API that makes it easy to create your own logging class. Each
log class should include the module {Ramaze::Logging}, this module provides the
basic setup for every logger and stops you from having to re-invent the wheel
every time.

    class MyLogger
      include Ramaze::Logging
    end

Each logger should respond to the instance method ``log()``. This method will be
used by other methods such as ``error()`` and ``warn()``, therefor your logger
is somewhat useless without this method. The ``log()`` method should take at
least two parameters, the first one the logging level (such as "error") and the
second (and all following parameters) should be messages to log. Lets add this
method to the ``MyLogger`` class shown above:

    class MyLogger
      include Ramaze::Logging

      def log(level, *messages)

      end
    end

Now you no longer get nasty errors when trying to log data. However, your data
is also completely ignored (after all, the method isn't doing anything yet).
What the ``log()`` method does is really up to you, whether you're logging to
STDOUT, to a file or to a database. A basic example of logging to STDOUT using
this class can be seen below.

    class MyLogger
      include Ramaze::Logging

      def log(level, *messages)
        messages.each do |message|
          $stdout.puts "#{level.upcase}: #{message}"
        end
      end
    end

When using this class the output will look like the following:

    ruby-1.9.2-p290 :011 > logger = MyLogger.new
     => #<MyLogger:0x00000101ae6328>
    ruby-1.9.2-p290 :011 > logger.info 'Hello Ramaze!'
    INFO: Hello Ramaze!

Of course it doesn't stop here. You can add colors, timestamps and pretty much
whatever you want.

## Available Loggers

* {Ramaze::Logger::Analogger}
* {Ramaze::Logger::Growl}: uses Growl for log messages (requires Mac OS).
* {Ramaze::Logger::LogHub}
* {Ramaze::Logger::Informer}
* {Ramaze::Logger::Knotify}
* {Ramaze::Logger::Logger}: wrapper around the Logger class from the Stdlib.
* {Ramaze::Logging}: basic skeleton for your own loggers.
* {Ramaze::Logger::RotatingInformer}: logger that rotates log files based on the
  current date.
* {Ramaze::Logger::Syslog}: logger that uses syslog.
* {Ramaze::Logger::Xosd}
