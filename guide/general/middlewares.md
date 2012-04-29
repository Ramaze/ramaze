# @title Rack Middlewares
# Rack Middlewares

Ramaze is a Rack based framework and thus allows you to create so called Rack
middlewares. Middlewares are basically objects that are stacked together
in order to intercept and process sequentially each incoming request and outgoing
response between Rack and Ramaze. You can think of a collection of middlewares
as a stack at whose bottom lies your Ramaze app.

The flow of a Rack request (including middlewares) looks as following:

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
by calling Ramaze#middleware!. This method accepts a block in which one defines
which middlewares to use for a specific mode and the name for this Ramaze mode
(Ramaze comes with "live" and "dev").

In the block you can call two Innate#MiddlewareCompiler methods
```use()``` and ```run()```. The ```use()``` method is used in order to add and
configure a middleware, while ```run()``` is used to determine what class is used
to run our Ramaze application. Unless you're using a custom class this should
always be set to {Ramaze::AppMap}.

Assuming we're running in "dev" mode our call will look like the following:

    Ramaze.middleware! :dev do |m|
      m.use(Banlist)
      m.run(Ramaze::AppMap)
    end

Note that when you use Ramaze#middleware! you also replace the previously setup
stack of middlewares. Therefore in order to add your new middleware on top of
the existing ones you either have to read-in each one using
``Innate#MiddlewareCompiler#middlewares`` and re-add it to the newly created
middleware stack or simply copy (lets say in your app.rb) what has been setup
inside ``lib/ramaze.rb``.

	current_mw = Ramaze.middleware(:dev).middlewares
	Ramaze.middleware! :dev do |mode|
  	  current_mw.each do |mw|
	    mode.use(mw[0],*mw[1], &mw[2]) # middleware, args, block
	  end

	  mode.use(Banlist)
	  mode.run(Ramaze::AppMap)
	end

