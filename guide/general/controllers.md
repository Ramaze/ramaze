# @title Controllers
# Controllers

When developing web applications controllers are the elements that are called
by a browser. When visiting a page a request is made that is processed by Rack
and sent to Ramaze. Ramaze in turn will determine what controller to call.

To make understanding controllers a bit easier will use a real world example.
Let's say we're in a restaurant and want to order some food. The waiter of the
restaurant can be seen as a controller. We'll talk to it and tell him what we
want to have for dinner but the waiter itself won't actually prepare our dinner,
instead it will merely tell the cooks to make the dinner and bring it to you once
it's done. The waiter is our controller, the cook is our model and our meal can
be seen as the view.

In a typical application the entire flow of a request is as following:

    Request --> Server (Thin, Unicorn, etc) --> Rack --> Ramaze --> Controller

## Ramaze & Controllers

In Ramaze controllers are plain Ruby classes that extend Ramaze::Controller. The
most basic controller looks like the following:

    class ControllerName < Ramaze::Controller
      map '/uri'

      def index

      end
    end

Let's walk through this snippet step by step. The first line declares a new
class that extends {Ramaze::Controller}. Extending this base class is very
important, without it we won't be able to call controller specific methods such
as the `map()` method. This method, which is called on line 2, is used to instruct
Ramaze what controller is bound to what URI (Uniform Resource Identifier). The
argument of this method should be a string starting with a /. The reason for
this is that the URIs are relative to URL the application is running on. For
example, if our application was running at ramaze.net a URI of "/blog" would
mean the controller can be found at ramaze.net/blog.

Let's move to the next lines of code. The next lines of code define a new method
called "index". By default Ramaze will try to call this method if no URI after
the mapped URI is given. In our /blog example a call to ramaze.net/blog would
call `BlogController#index` but a call to `ramaze.net/blog/entry/10` would call
`BlogController#entry(10)`.

All methods that are declared as public can be accessed by a user and by default
the `index()` method is called if no other method is specified. Don't like the
`index()` method? No problem, you can specify a different default method to call
as following:

    class ControllerName < Ramaze::Controller
      trait :default_action_name => 'default'

      def default

      end
    end

We're not going to cover Traits too much in this chapter as there's a dedicated
chapter for them but in short they're a way of setting configuration options. In
this case we're using the trait `default_action_name` to specify what the name
of the default method should be. By default this is set to "index" but in the
above example it was changed to "default".

### Method Arguments

As mentioned above methods are bound to URLs given they're declared as public
methods. The same applies to the arguments of such methods, if the method is
public these arguments can be set from the URL. This means that you don't have
to use a special DSL just to bind methods to certain URLs while taking various
parameters into account. An example is the following:

    class Pages < Ramaze::Controller
      map '/pages'

      def index
        # Overview of all pages
      end

      def edit(id)
        # Edit the page for the given ID
      end
    end

This controller would allow users to navigate to `/pages/edit/10` which would
invoke `Pages#edit("10")`. There's no restriction on the values of parameters
(as long as they don't include slashes), they are however always passed as
strings to the method.

One thing to keep in mind is that if a method takes a set of required parameters
that are *not* specified Ramaze will *not* call the method, it will instead show
a message that the request could not be executed due to a missing
method/controller (unless your application has a custom handler for this).

Using the code above navigating to `/pages/edit/10` would work but navigating to
`/pages/edit` would not since the "id" parameter is specified as a required
parameter but wasn't given in the URL. Don't worry, working around this is as
easy as specifying a default value for your parameters:

    class Pages < Ramaze::Controller
      map '/pages'

      def index
        # Overview of all pages
      end

      def edit(id = nil)
        # Edit the page for the given ID
      end
    end

With this modification the `edit` method will be called for URLs such as
`/pages/edit`, `/pages/edit/10` and so on.

### Catch-all Methods

Sometimes you want to create a controller in which a single method handles all
the requests. This can be done by creating an `index` method that takes a
variable amount of parameters:

    class Pages < Ramaze::Controller
      map '/pages'

      def index(*args)

      end
    end

In this example `Pages#index` would be called for URLs such as `/pages`,
`/pages/example`, `/pages/edit/10` and so on. The exception to this is URLs that
point to existing methods. An example:

    class Pages < Ramaze::Controller
      map '/pages'

      def index(*args)
        return 'index'
      end

      def example
        return 'example'
      end
    end

If a user were to browse to `/pages/hello` the index method would be called and
"index" would be displayed, when the user instead goes to `/pages/example` the
text "example" would be displayed as there's an existing method for this URI.
However, if the user would request `/pages/example/10` the index method would
again be called, this is because the example method does not take any
parameters. Below is a list of various URLs and what method calls they'd result
in.

    /pages            # => Pages#index
    /pages/index      # => Pages#index
    /pages/edit/10    # => Pages#index("edit", "10")
    /pages/example    # => Pages#example
    /pages/example/10 # => Pages#index("example", "10")

## Registering Controllers

By now you might be thinking "How does Ramaze know what controller to call? I
didn't initialize the controller!". It's true, you don't have to manually
initialize the controller and save it in a hash or somewhere else. The entire
process of registering a controller is done by the map() method and thus is one
of the most important methods available. When calling this method it will store
the name of the class that invoked it and bind it to the given URI. Whenever a
request is made Ramaze simply creates an instance of the matching controller
for a given URI.

The basic process of the map() method is as following:

1. Call `map()`.
2. Validate the given URI.
3. Store the controller constant.
4. Done.

## Base Controllers

In many applications you'll have separate areas such as an admin panel and the
frontend. Usually you want to authenticate users for certain controllers, such
as those used for an admin panel. An easy way of doing this is by putting the
authentication call in a controller. By creating a base controller and extending
it you don't have to call the method that authenticates the user over and over
again. Because Ramaze is just Ruby all you have to do to achieve this is the
following:

    class AdminController < Ramaze::Controller

    end

    class Users < AdminController

    end

If your base controller has an initialize() method defined you should always
call the parent's initialize() method to ensure everything is working properly.
This can be done by calling super():

    class AdminController < Ramaze::Controller
      def initialize
        # Calls Ramaze::Controller#initialize
        super

        # Custom calls can be placed here...
        # ...
      end
    end
