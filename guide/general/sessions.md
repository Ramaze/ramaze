# Sessions

The term sessions is used for data associated to a specific client. The easiest
example of a session is a simple cookie containing some very basic data such as
a user's name.

## Initializing Sessions

Ramaze lazy-loads the session system that it's ship with. This means that if you
never use any session related data a session will not be created. As soon as you
call the main object for working with sessions (simply called "session") or add
data to the flash (more on that later) Ramaze will load the session adapter
automatically. This prevents you from having to manually write code that invokes
a session for all your projects.

So how do we actually start a session? As mentioned earlier this can be done in
two different ways, calling session or flash. If you want to store data in the
session until the client's session is destroyed (or the data is removed) it's
best to use session, if you only want to store something until the client is
redirected to another page (or just visits a page himself) you should use flash.

## The Session Object

As mentioned earlier session is used for data that should be stored until the
client's session is destroyed or the data is removed. A good example of this
sort of data is a  boolean that indicates if the user is logged in or not, you
don't want the user to re-authenticate over and over again thus you store the
data using the session object. Storing data using this method is incredible
simple and works a bit like you're storing data in a hash:

    session[:logged_in] = true

In the above example we stored a boolean with a value of "true" in the current
client's session under the name ":logged_in". If we want to retrieve this data
somewhere else in the application all we'd have to do is the following:

    session[:logged_in] # => true

A better example would be a simple counter that tracks the amount of times a
user has visited your application:

    class Counter < Ramaze::Controller
      map '/'

      def index
        # If no data was found for the given key session returns nil
        if !session[:visits].nil?
          session[:visits] = 0
        else
          session[:visits] += 1
        end

        "You have visitied this page #{session[:visits]} times."
      end
    end

In this relatively basic controller a user's amount of visits to the index()
method will be stored in the session and displayed afterwards. Now it's time
for the true magic. The session object is an instance of Innate::Session and
has a few extra methods besides [] and []=. These methods are delete(), clear(),
flush(), resid!() and sid(). We're not going to cover all methods but we will
look at the delete() and resid() methods.

## Session.delete

The method Session.delete can be used to remove a chunk of data from the
client's session. In order to delete our amount of visits all we'd have to do
is the following:

    session.delete(:visits)

From this point on the "visits" key is set to nil until the user visits the
index page again.

## Session.resid!

Session.resid! can be used to regenerate the client's session ID without
destroying the session data. This method is extremely useful for authentication
systems as it can be used to prevent session fixation attacks by generating a
new session ID every N minutes or whenever a certain action is triggered (e.g.
the user logs in). Using this method is very simple and only requires the
following to be done:

    session.resid!

## The Flash

First of all, this has nothing to do with Adobe's Flash or
[The Flash][the flash]. Flashdata is a form of session data that is removed as
soon as the client requests a new resource. This means that if something is
stored in the flash and the user is redirected the data will be automatically
removed. One of the things the flash data can be used for is storing
notifications that are displayed if a blog post has been saved successfully.
Storing data in the flash works similar to storing data in the session and can
be done by calling the flash object:

    flash[:message] = "Hello, Ramaze!"

If we want to remove something from the flash we can call Flash.delete similar
to Session.delete:

    flash.delete(:message)

Note that due to the nature of the flash data you'd have to do this before the
client requests a new resource as the data will be deleted automatically at
that point.

To integrate flash with your application views include {Ramaze::Helper::Flash}
in your controller and call function ``flashbox`` inside the view.

To change the markup of the flashbox generated HTML, use the following trait
inside your controller:

    trait :flashbox => "<div class=\"alert-message %key\"><p>%value</p></div>"

Below is an example of how the flash data can be used in a typical Ramaze
application:

    class Blogs < Ramaze::Controller
      map '/'
      helper :flash

      def index
        flash[:message]
      end

      def set_message
        flash[:message] = "Hello, Ramaze!"
        redirect(Blogs.r(:index))
      end
    end

If a client were to visit the index method for the first time nothing would be
displayed because the flash data isn't there yet. As soon as the client visits
/set_message he would be redirected back to the index method and the message
"Hello, Ramaze!" would be displayed. Refreshing the page would clear the flash
data and the message would no longer be displayed until the client visits
/set\_message again.

[the flash]: http://en.wikipedia.org/wiki/The_Flash_(comic_book)
