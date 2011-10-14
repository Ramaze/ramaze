# Rack Middlewares

Ramaze is a Rack based framework and thus allows you to create so called
middlewares. Middlewares are basically classes that can be used to intercept the
communication between Rack, Ramaze and the visitor as well as providing common
functionality such as logging of requests. The flow of a Rack request (including
middlewares) looks as following::

    Request --> Server (Thin, Unicorn, etc) --> Rack --> Middleware(s) -->
    Ramaze  --> Controller

Say we want to ban a number of users by IP, there are two ways of doing this.
The first way of doing this would be to validate the user's IP in all controllers
(or in a base controller). However, this approach will eventually require quite
a bit of code. The easier method, as you may have guessed, is using a Rack
middleware. Since middlewares are executed for each request this means we'll
only have to add our code once and we're good to go.

## Building the Middleware

Let's begin building our IP blacklist. For the sake of simplicity we'll hardcode
the blocked IPs in an array stored inside our middleware. Go ahead and create a
file called "banlist.rb" and save it somewhere in your application (and require
it!). We'll begin with our basic skeleton that looks like the following:

    class Banlist
      def initialize(app)
        @app = app
      end

      def call(env)

      end
    end

First we declare a new class called "Banlist". Followed by this is our construct
method that takes a single argument: an object containing the details of our
Ramaze application. Next up is the call() method which also takes a single
argument but this time it's an object containing our environment details such as
the POST and GET data.

Let's add a list of blocked IPs to our middleware. Modify the initialize()
method so that it looks like the following:

    def initialize(app)
      @app    = app
      @banned = ['189.3.0.116', '193.159.244.70', '193.46.236.*']
    end

We now have 3 blocked IPs. Time to actually implement the blocking mechanism in
our call() method. Modify it as following:

    def call(env)
      if @banned.include?(env['REMOTE_ADDR'])
        return "You have been banned!"
      else
        @app.call(env)
      end
    end

So what did we do? Quite simple actually, we extracted the user's IP by calling
``env['REMOTE_ADDR']`` and checked if it's stored in the @banned instance
variable. If it is we'll block the user and show a message "You have been
banned". Our final middleware looks like the following:

    class Banlist
      def initialize(app)
        @app    = app
        @banned = ['189.3.0.116', '193.159.244.70', '193.46.236.10']
      end

      def call(env)
        if @banned.include?(env['REMOTE_ADDR'])
          return "You have been banned!"
        else
          @app.call(env)
        end
      end
    end

## Using Middlewares

Now it's time to tell Ramaze to actually use the middleware. This can be done
by calling Ramaze#middleware!. This method takes a block that defines what
middlewares to use for what environment. Assuming we're dunning in "dev" mode
our call will look like the following:

    Ramaze.middleware! :dev do |m|
      m.use(Banlist)
      m.run(Ramaze::AppMap)
    end

When calling the ``middleware!()`` method it's first argument should be a
development mode to use (Ramaze comes with "live" and "dev"), the method also
accepts a block which is used to determine what middlewares to use and to run
Ramaze ({Ramaze::AppMap}). In this block you can call two methods, use() and
run(). The first method is used to add a middleware and configure it, the run()
method is used to determine what class is used to run our Ramaze application.
Unless you're using a custom class this should always be set to
{Ramaze::AppMap}.
