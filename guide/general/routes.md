# Routes

While in many cases the default route system that comes with Ramaze is good
enough there will be times when you want pretty URLs (or just different ones).
Ramaze allows you to do all this using the class Ramaze::Route (it's an alias
of Innate::Route). This class allows you to create routes using simple strings,
regular expressions and lambdas. Let's say we have the following URLs:

* /users/index
* /users/profile/yorickpeterse
* /users/edit/yorickpeterse

Our goal is to rewrite these URLs to the following:

* /users/list
* /users/yorickpeterse
* /users/yorickpeterse/edit

In order to fully explain the routing system will use the three available
possibilities: strings, regular expressions and lambdas.

## String Routes

Routes that use a string are the most basic form of routing. You simply specify
a request URI and the action to call instead of the normal one:

    Ramaze::Route['/foobar'] = '/baz/bar'

This route tells Ramaze that every request to /foobar should be sent to /baz/bar
instead. While string based routes are the easiest to use they're also the most
limited one, they can merely be used to redirect A to B. If we look at our list
of URLs the only one we can rewrite using this form of routing is the first one:

    Ramaze::Route['/users/list'] = '/users/index'

This forwards all requests that were sent to /users/list to /users/index.

## Regular Expression Routes

Using regular expressions in routes makes it possible to have more dynamic
routes. Routes that use regular expressions look like the following:

    Ramaze::Route[/user-([0-9]+)/] = '/users/%d'

This route forwards requests such as /user-10 and /user-1234 to /users/10 and
/users/1234. As you can see there's a "%d" in the value which is replaced with
the value of the group ([0-9]+). When using regular expressions for your routes
you can use sprintf characters in the value (%s, %d, etc).

So what about our list of URLs? Let's rewrite the second URL:

    Ramaze::Route['/users/([\w]+)'] = '/users/profile/%s'

And there we go, all calls to /users/NAME (where NAME is the name of a user)
will be routed to /users/profile/NAME.

## Lambda Routes

The last method of routing calls can be done using lambdas. The key of the []=
method will be the name of a route (can be anything really) and the value a
lambda that takes two parameters, the request path and a variable containing the
request data:

    Ramaze::Route['my funky lambda route'] = lambda do |path, request|

    end

In this lambda you're free to do whatever you want as long as you either return
a new path or nil (anything else will result in an error). Say we wanted to
route our last URL we'd do it as following:

    Ramaze::Route['edit users'] = lambda do |path, request|
      if path =~ /users\/edit\/([\w]+)/
        return "/users/#{$1}/edit"
      end
    end

This route redirects everything from /users/NAME/edit to /users/edit/NAME.
Everything else is unaffected by this route since it only returns a value when
the path matches the given regular expression. Note that lambdas can actually
contain a "return" statement so the code above is perfectly valid.
