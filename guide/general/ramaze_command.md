## Ramaze Command

Ramaze ships with a relatively simple command, named "ramaze". This command can
be used to create new applications as well as starting them. To make reading
this guide easier we'll call this command "bin/ramaze" from now on.

<div class="note deprecated">
    <p>
        <strong>Warning</strong>: bin/ramaze is not a scaffolding application.
        It can merely be used for some basic application management and creating
        a basic Ramaze application.
    </p>
</div>

## Creating Applications

As mentioned earlier bin/ramaze can be used to create new applications. In order
to create a new application in the current directory all you have to do is
executing the following command:

    $ ramaze create APPNAME

APPNAME is the name of your new application and will also be used as the
directory name. If the application was named "blog" there would now be a
directory called "blog" in the current one. This directory will contain all
basic files that can be used for a Ramaze powered application.

Each new application has the following structure:

    .__ app.rb
    |__ config.ru
    |__ controller
    |   |__ init.rb
    |   |__ main.rb
    |
    |__ layout
    |   |__ default.xhtml
    |
    |__ model
    |   |__ init.rb
    |
    |__ public
    |   |
    |   |__ css
    |   |   |__ screen.css
    |   |
    |   |__ dispatch.fcgi
    |   |__ favicon.ico
    |   |__ js
    |   |   |__ jquery.js
    |   |
    |   |__ ramaze.png
    |
    |__ spec
    |   |__ main.rb
    |
    |__ start.rb
    |__ view
        |__ index.xhtml

## Application Prototypes

Due to Ramaze's nature it's very easy to create your own application prototype
if you dislike the default one. For example, I've made some small modifications
to the default prototype so that it looks like the followng:

    .__ app.rb
    |__ config
    |   |__ config.rb
    |   |__ database.rb
    |   |__ middlewares.rb
    |   |__ requires.rb
    |
    |__ config.ru
    |__ controller
    |__ layout
    |   |__ default.xhtml
    |
    |__ log
    |__ public
    |__ spec
    |__ start.rb
    |__ view

This prototype is basically a minimal version of the default one but with a
special directory for all configuration files. In order to use this prototype I
had to make some small changes to app.rb, the look like the following:

    require 'ramaze'

    # Load the file that in turn will load all gems, keeps this file clean
    require __DIR__('config/requires')

    # Configure our application
    require __DIR__('config/config')

    # Load our database settings
    require __DIR__('config/database')

    # Load all Rack middlewares
    require __DIR__('config/middlewares')

    # Load all controllers
    Dir.glob(__DIR__('controller') + '/**/*.rb').each do |f|
      require f
    end

This is only a basic example of the flexibility of Ramaze, I highly recommend
you playing around with your own prototypes as it's a great way to learn the
basics of Ramaze and to really understand how flexible Ramaze is.


<div class="note todo">
    <p>
        <strong>Note</strong>: This prototype does not come with Ramaze, it's
        just an example of what you could make yourself.
    </p>
</div>

## Running Applications

When you've created an application there are three ways of running it. You can
either use your server's command such as `thin` or `unicorn` but you can also
use bin/ramaze. When starting your application with bin/ramaze it will use the
appropriate server according to the settings set in "config.ru" or "star.rb".
An example of using this command is as simple as the following:

    $ ramaze start

On top of these two ways you can also start your Ramaze application by calling
the "start.rb" file using the ruby binary:

    $ ruby start.rb

If you want to stop the running application you can simply close it by using the
key combination Ctrl+C.

<div class="note todo">
    <p>
        <strong>Note</strong>: There are many different ways to start your
        application depending on the server you're using. Fore more information
        it's best to look at the documentation of your favorite webserver.
    </p>
</div>

## Ramaze Console

The bin/ramaze command allows you to run an interactive Ramaze session just
like IRB. In fact, Ramaze actually uses IRB. To invoke the Ramaze console simple
execute `ramaze console` and you're good to go. This console gives you full
access to your application and thus can be very useful for debugging purposes.

An example of a Ramaze console session can be seen in the image below.

![Ramaze Console](_static/ramaze_console.png)
