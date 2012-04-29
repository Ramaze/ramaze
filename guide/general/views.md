# @title Views
# Views

Views are the last step in the process of a request to a MVC framework such as
Ramaze. A controller loads a model, the model processes a certain amount of
data and the controller will then pass this data to a view. The typical flow of
a MVC framework (or any framework using a view system) looks like the following:

    Request --> Controller --> View
                  ^ |
                  | '--> Model
                  |        |
                  '--<-----'

The contents of a view is what the visitor of a page will eventually see.
Looking back at the waiter example introduced in the :doc:`controllers` chapter
a view can be seen as our dinner. It's the end result we requested for but it
has been modified according to our order.

Ramaze has support for many different template engines and thus views can look
quite different. By default Ramaze uses a simple template engine called "Etanni",
Etanni was developed by Michael Fellinger exclusively for Ramaze and is a very
fast template engine. In this chapter we'll use Etanni to make it a bit easier
to understand how views work.

## Layouts

Ramaze also has a concept of layouts. Layouts are basically views for views and
are placed in the "layout" directory of your application. These views can be
used to display generic elements such as a navigation menu for all views.
Because of this it's recommended to only place action specific markup in your
views. Global elements such as navigation menus or page titles should go in a
layout.

In order to render a view inside a layout all you have to do is calling the
"content" instance variable. If we were to use Etanni (more on this later) our
code would look like the following:

    <div id="container">
        #{@content}
    </div>

In order to use a layout we have to tell Ramaze to do so in our controller.
Setting a layout can be done in a few different ways. The easiest way is using
the method "layout" in your controller as following:

    class Blogs < Ramaze::Controller
      layout 'default'
    end

This will tell Ramaze to use the layout "default.xhtml" for the Blogs controller.
While suited for most people there comes a time when you're in the need of a
more dynamic way of assigning a layout. This can be done in two different ways.
The first way is passing a block to the layout() method:

    class Blogs < Ramaze::Controller
      layout do |path|
        if path === 'index'
          :index_layout
        else
          :alternative_layout
        end
      end
    end

In this example two layouts are used, `index_layout` for the index() method and
`alternative_layout` for all other methods.

The second way is using the method `set_layout`. This method works almost
identical to layout() but has one big advantage: it can set method specific
layouts. Changing the code posted above so that it uses this method would look
like the following:

    class Blogs < Ramaze::Controller
      # Set our default layout
      layout 'alternative_layout'

      # Set our layout for the index() method
      set_layout 'index_layout' => [:index]
    end

The `set_layout` method takes a hash where the keys are the names of the layouts
to use and the values the methods for which to use each layout. Below is another
example that specifies a few extra layout/method combinations.

    class Blogs < Ramaze::Controller
      # Set our default layout
      layout 'default'

      # Set our layout for the index() method
      set_layout 'main' => [:index, :edit], 'extra' => [:add, :synchronize]
    end

## Loading Views

Loading views can be done in two different ways. When not explicitly calling a
certain view (or returning any data from the controller) Ramaze will try to load
a matching view for the current action. If the method "edit" was called Ramaze
will try to load a view called "edit". Manually sending a response back can be
done by returning a string from the controller method that is called. Take a
look at the example below.

    class Blogs < Ramaze::Controller
      map '/'

      def index

      end

      def custom
        "This is my custom response!"
      end

      def other
        render_view :foobar
      end
    end

If the user were to visit /index Ramaze would try to load the view "index.xhtml"
(``.xhtml`` is the extension for Etanni templates) but when the user goes to
/custom he'll always see the message "This is my custom response!". This is
because Ramaze will use the return value of a controller method as the body for
the response that will be sent back to the visitor.

Let's take a look at the other() method in our controller. As you can see it
calls a method `render_view`. This method is used to render a different view
(in this case foobar.xhtml) but without calling it's action, once this is done
the contents of the view will be returned to the controller. When calling custom
views you can use any of the following methods:

* render\_view
* render\_partial
* render\_file
* render\_custom
* render\_full

### render\_view

As mentioned earlier this method is used to render a view without calling it's
action. This can be useful if you have several methods that share the same view
but feed it different data. The usage of this method is quite simple, it's first
argument is the name of the view to load (without the extension, Ramaze will
figure this out) and the second argument is a hash containing any additional
variables to send to the view (more on this later).

    # Render "foo.xhtml"
    render_view :foo

    # Render "foo.xhtml" and send some extra data to it
    render_view :foo, :name => "Ramaze"

### render\_partial

The `render_partial` method works very similar to the `render_view` method, the
difference is that the `render_partial` method will not render a layout while
`render_view` will. This makes the `render_partial` method useful for responses
to Ajax calls that don't need (or don't want to) load both the view and the
layout. This method has the same arguments as the `render_view` method.

    # Render the view "partial.xhtml"
    render_partial :partial

    # Render the partial "partial.xhtml" and send some extra data to it
    render_partial :partial, :name => "Ramaze"

### render\_file

There comes a time when you may want to render a file that's located somewhere
else. For this there is the `render_file()`` method. This method takes a path,
either relative or absolute to a file that should be rendered. This can be
useful if you have a cache  directory located outside of your project directory
and you want to load a view from it.

The first argument of this method is a path to a file to render, the second
argument is a hash with variables just like the other render methods.
Optionally this method accepts a block that can be used to modify the current
action.

    # Render a file located in /tmp
    render_file '/tmp/view.xhtml'

    # Render a file and send some extra data to it
    render_file '/tmp/view.xhtml', :name => "Ramaze"

    # Render a file and modify the action
    render_file '/tmp/view.xhtml' do |action|
      # Remove our layout
      action.layout = nil
    end

### render\_custom

The render_custom() method can be used to create your personal render method and
is actually used by methods such as the render_partial method. The syntax is the
same as the render_file() method except that instead of a full path it's first
argument should be the name of the action to render.

    render_custom :index do |action|
      # Remove the layout
      action.layout = nil

      # Render the view without calling a method
      action.method = nil
    end

### render\_full

Last but not least there's the render_full() method. This is the method Ramaze
uses for calling a controller along with it's views and such. This method takes
two arguments, the first is the full path of the action to render and the second
a hash that will be used for the query string parameters. Please note that if this
method is called in the first request of a client you won't have access to the
session data and such, any following calls will have access to this data.

    # Calls Blogs#index
    render_full '/blog/index'

    # Calls Blogs#edit(10)
    render_full '/blog/edit/10'

### Assigning Data

Assigning data to a view is very simple. Ramaze will copy all instance variables
from the current controller into the view. This means that if you have a variable
@user set to "Yorick Peterse" this variable can be displayed in your view as
following (assuming you're using Etanni):

    <p>Username: #{@user}</p>

Besides this you can assign custom data to a view by calling any of the render
methods and passing a hash to them.

Please note that the behavior or the syntax of displaying variables may change
depending on the template engine you're using. While Etanni allows you to execute
plain Ruby code in your view a template engine such as Mustache won't and thus
may have a different syntax. If we wanted to use Mustache and display our @user
variable it would have to be done as following:

    <p>Username: {{user}}</p>

## View Mapping

Views are saved in the directory "view" and are saved according to the controller
mapping. If you have a controller that's mapped to /modules/blog the index view
will be located at view/modules/blog/index.xhtml. Below are a few examples that
show where the views are located when passing different values to the map()
method.

    map '/'             # view/index.html, view/edit.xhtml, etc
    map '/blog'         # view/blog/index.xhtml, view/blog/edit.xhtml, etc
    map '/modules/blog' # view/modules/blog/index.xhtml, view/modules/blog/edit.xhtml, etc

## Template Engines

Ramaze ships with support for the following template engines:

* Erector
* Etanni
* Erubis
* Ezamar
* HAML
* Less
* Gestalt
* Liquid
* Lokar
* Mustache
* Nagoro
* Remarkably
* Sass
* Slippers
* Tagz
* Tenjin

All of these engines can be used on a per controller basis by calling the
engine() method and passing a symbol or string to it.

    class Blogs < Ramaze::Controller
      engine :etanni
    end

The engine() method uses the provide() method (more on that in a second) to set
the given engine for all data sent back to the visitor with a content type of
"text/html". If you want to use a certain engine for a different content type
(e.g. application/json) you can do so using the provide() method:

    class Blogs < Ramaze::Controller
      # Simple right?
      provide(:json, :erb)

      # Somewhat more verbose
      provide(:json, :engine => :erb)

      # AWESOME!
      provide(:json, :type => 'application/json') do |action, value|
        # "value" is the response body from our controller's method
        value.to_json
      end
    end

It's important to remember that the actions in the provide() method will only
be executed if it's first parameter (in this case "json") are appended to the
URL as an extension. A request to /hello would output HTML when using the above
code, if we wanted JSON we'd have to send a request to /hello.json.

The default template engine used by Ramaze is Etanni. Etanni is a small template
engine that ships with Ramaze (and Innate!) that's extremely fast and has a very
simple syntax. Statements are wrapped in <?r ?> tags and rendering data can be
done by wrapping the variables in ``#{}``:

    # <?r ?> accepts regular Ruby code
    <?r if @user.name === 'yorick' ?>
    <p>Hello Yorick</p>
    <?r else ?>
    <p>And who are you?</p>
    <?r end ?>

    # Display our name
    #{@user.name}

Etanni can be very useful for most project but it's *not* recommended to use it
when you want to allow a client to manage certain templates (e.g. Email layouts).
This is because Etanni allows you to execute regular Ruby code and thus someone
could do some serious damage to your server without even knowing it.
