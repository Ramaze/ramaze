# Introduction Tutorial

This tutorial focuses on teaching the basics of Ramaze. Before reading this
tutorial it's recommended that you first read some of the other chapters to get
a bit of an understanding what Ramaze really is and what it does. It's required
that you've read the following chapters before reading this tutorial (or any of
the other tutorials):

* {file:README READE}
* {file:general/installation Installation}

In this tutorial we'll cover te following:

* Creating applications and running them.
* Debugging applications using ``ramaze console``
* Basic introduction to controllers and views.

<div class="note todo">
    <p>
        <strong>Note</strong>: Do not blindly copy-paste the code found in this
        tutorial. It's extremely important that you type it manually as this
        makes the learning process much easier and faster.
    </p>
</div>

## Creating Applications

Creating applications can be done in two different ways, using the Ramaze
executable (called "ramaze") or by manually writing the code. In this tutorial
we'll use the last approach as it teaches more about what each file does. If
you're interested in learning more about the executable read the chapter
{file:general/ramaze_command Ramaze Command}.

The first step is to create our project directory, let's call it "tutorial"::

    $ mkdir tutorial
    $ cd tutorial

Each Ramaze application requires a Rackup configuration file ("config.ru") and
a base file that's used to load all the bits and pieces of your application,
typically called "app.rb". The Rackup configuration file is used to tell
webservers such as Thin or Unicorn how they should run Ramaze. Let's start with
the Rackup file:

    require ::File.expand_path('../app', __FILE__)

    Ramaze.start(:root => Ramaze.options.roots, :started => true)

    run Ramaze

The first line of code is used to load our main file "app.rb" (more on this in
a bit). The path is constructed so that the file is loaded from the same
directory as the config.ru file. The next line is used to start Ramaze and tell
it that it's running as well as setting the root directory from which the
command should be executed. The last line simply tells Rack to start Ramaze.
Simple right? No? Well here's the good part, you should only have to write this
code once. If you're lazy you can just copy-paste the code above and save
yourself some time.

The next step is to create our app.rb file. Note that this file can be named
anything you like but in all the tutorials "app.rb" will be used, on top of
that it's somewhat of a standard so it's best to just stick with the name. The
contents of this file can be anything you like as long as it contains the
following two lines of code:

    require 'rubygems' # Only required on Ruby < 1.9
    require 'ramaze'   # Always required

This will load the Ramaze gem, without it you won't be able to create a Ramaze
application. Besides this you'll obviously need to load a few more files in
order to get a working application. Let's create our first controller and load
it in this file, because we've already opened app.rb we'll just add the require
statement for it right away:

    require __DIR__('controller/tutorial')

This line of code will tell Ruby to load the file "tutorial.rb" from
$DIR/controller/ where $DIR is the project directory. __DIR__ is a special
method provided by Ramaze that basically does the same as the following:

    File.expand_path("../#{some_path}", __FILE__)

Whenever you want to load something relative to a file it's best to use
__DIR__ (or require_relative if you're on 1.9).

Right, time to create the controller we just loaded (don't actually start the
application, it will trigger an error!)::

    $ mkdir controller/
    $ touch controller/tutorial.rb

Now open the tutorial.rb file in your favorite editor. Obviously this file is
still empty so we'll need to add some code to the file. We'll be creating a
class called "Tutorial" that will be mapped to "/" (the root of your
application). This can be done as following:

    class Tutorial < Ramaze::Controller
      map '/'
    end

It's important that you always extend Ramaze::Controller, whether it's extended
directly or via another class. Without this Ramaze won't recognize the class as
a controller nor will you be able to use controller specific methods.

## Running Applications

Currently we have the following files:

* config.ru
* app.rb
* controller/tutorial.rb

Let's see if our application is working, start it with the following command::

    $ ramaze start

If everything went well the output of this command should look like the
following::

    [2011-05-24 17:37:31] INFO  WEBrick 1.3.1
    [2011-05-24 17:37:31] INFO  ruby 1.9.2 (2011-02-18) [x86_64-darwin10.7.0]
    [2011-05-24 17:37:31] INFO  WEBrick::HTTPServer#start: pid=74568 port=7000

If you now were to navigate your browser to http://localhost:7000/ you'd get the
following response:

    No action found at: "/"

This message is displayed because while there is a controller (Tutorial) it
doesn't have any methods available for the requested URI. Let's go ahead and add
a method to our controller, shut down WEBRick (Ctrl + C) and open the file
controller/tutorial.rb. Modify it so that it's code looks like the following:

    class Tutorial < Ramaze::Controller
      map '/'

      def index
        "Hello, world!"
      end
    end

Save the file and restart WEBRick using ``ramaze start``. If you now refresh
the page you'd see the message "Hello, world!" opposed to the "No action found.."
message. This is because we now have a method for the URI "/". Ramaze maps the
public methods of a controller to the URI of the controller. This means that if
you added another method to this controller named "cookie" you'd be able to
access it from /cookie. The method used for a URI of / is "index" by default but
this can be changed as following:

    class Tutorial < Ramaze::Controller
      map '/'

      trait :default_action_name => 'default'

      def default
        "Hello, world!"
      end
    end

The trait() method is a method provided by Ramaze that can be used to set
configuration options in a class, don't worry about it for now.

Obviously a plain text message is boring, let's get started with "views". Views
are files that will contain the presentation layer (usually HTML) of your
application. In order to create a view we'll have to create a view directory
first::

    $ mkdir view/

In order to render a view you'll have to create a view that matches a method's
name and is placed in the correct directory. In this case our method is called
"index" and the controller is mapped to /. This means that our view would be
located in view/index.xhtml. If our method was named "default" the view would
be in view/default.xhtml. If the controller was mapped to /cookie the view would
be located in view/cookie.index.xhtml and so on. Let's create and edit the file::

    $ touch view/index.xhtml
    $ $EDITOR view/index.xhtml

Just like all the other files this one is empty. A view can contain HTML and
Ruby code based on the template engine you're using. By default Ramaze uses
Etanni which allows you to wrap your Ruby code in #{} for outputting variables
and <?r ?> for statements:

    <?r if !@username.nil? ?>
    #{@username}
    <?r end ?>

Let's add the following data to the view:

    <p>Hello, #{@username}!</p>

Once this is done modify your Tutorial controller so that it looks like the
following:

    class Tutorial < Ramaze::Controller
      map '/'

      def index
        @username = "Ramaze"
      end
    end

From this point on all requests made to / will not result in a response of
"Hello, world!" but instead will display "Hello, Ramaze!". The cool thing is
that you don't have to manually load the view (but you still can if you like).
If the method of a controller has no return value Ramaze will try to load the
corresponding view.

## Debugging Applications

Quite often you'll want to quickly look something up, say the list of available
methods of a class, in your application. A common approach is to restart your
application every time
you've made your changes but this can become really annoying. To solve this issue
Ramaze comes with the command ``ramaze console``. This command basically loads
IRB along with your application, allowing you to play with it without having to
restart your server every time.

In order for us to be able to use the console we'll have to add a new file to
our project, called "start.rb". start.rb works the same as config.ru but
instead of being used for Rackup it's used to tell Ramaze how to run it in IRB.
Create the file and open it in your editor ($EDITOR is the command used for
opening a file in your editor)::

    $ touch start.rb
    $ $EDITOR start.rb

Add the following code to it:

    require File.expand_path('../app', __FILE__)

    Ramaze.start(:adapter => :webrick, :port => 7000, :file => __FILE__)

Anything that looks familiar? This code is almost identical except that instead
of calling "run Ramaze" it invokes the Ramaze.start command without telling it
it will be started by something else (this is done using the :started option).
Don't bother too much about this file as it's pretty boring, save it and leave
it alone.

Now that we've added the required file we can invoke the console. This is done
as following::

    $ ramaze console
    ruby-1.9.2-p180 :001 >

You can use the console for everything you'd normally use IRB for but it comes
with the added value of being able to do Ramaze specific things::

    ruby-1.9.2-p180 :001 > Ramaze.options.app.name
     => :pristine

If you're done playing you can close the console with Ctrl + D.

And that's really about it. While we've only scratched the surface of Ramaze
we've already managed to write some Ramaze specific code as well as learning
how to use the console and how to start applications. The source code created in
this tutorial can be found here:
https://github.com/Ramaze/ramaze-user-guide-code/tree/master/introduction
