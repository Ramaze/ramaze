# Ramaze

Ramaze is a very simple and straight-forward web-framework. The philosophy of
it could be expressed in a mix of KISS and POLS, trying to make simple things
simple and complex things possible.

This of course is nothing new to anyone who knows some Ruby, but is often
forgotten in a chase for new functionality and features. Ramaze only tries to
give you the ultimate tools, but you have to use them yourself to achieve
perfect custom-tailored results.

Another one of the goals during development of Ramaze was to make every part as
modular and therefore reusable as possible, not only to provide a basic
understanding after the first glance, but also to make it as simple as possible
to reuse parts of the code.

The original purpose of Ramaze was to act as a kind of framework to build
web-frameworks, this was made obsolete by the introduction of Rack, which
provides this feature at a better level without trying to enforce any structural
layout of the resulting framework.

Today Ramaze serves as a framework for those who want to develop their projects
in their own way rather than being forced to work in a way that the framework
(and its creators) define. It tries not to make any assumptions and more
importantly: it puts you back in control of your code. An example of this is the
default file structure of new Ramaze projects.  Out of the box a new project
uses the MVC pattern. The cool thing about Ramaze however is that you're not
forced to use this pattern. If you prefer HMVC, PAC or something else you can
simply apply it. Another example is the use of a database toolkit. Ramaze does
not ship with one for a very simple reason: nobody likes the same toolkit. Some
people prefer Sequel, others use Datamapper. With Ramaze you can use any tool
you like.

Installing Ramaze is as easy as the following command:

    $ gem install ramaze

For more information see the chapter {file:installation Installation}.

<div class="note todo">
    <p>
        <strong>Note:</strong> if you spot any mistakes made such as spelling
        errors or links not working feel free to report them on the mailing
        list, in the IRC channel or by submitting a bug at the
        <a href="https://github.com/ramaze/ramaze/issues">bugtracker</a>.
    </p>
</div>

## Quick Example

While Ramaze applications are usually spread across multiple directories for
controllers, models and views one can quite easily create a very basic
application in just a single file:

    require 'ramaze'

    class MyController < Ramaze::Controller
      map '/'

      def index
        return "Hello, Ramaze!"
      end
    end

    Ramaze.start

Once this is saved in a file (you can also run this from IRB) simply execute it
using the Ruby binary:

    $ ruby hello_ramaze.rb

This starts a WEBRick server listening on localhost:7000.

## Requirements

* Innate (which in turn requires Rack).
* A Ruby implementation based on Ruby 1.8 or newer (1.9.2, Rubinius, etc).
* A Rack server such as Thin or Unicorn.
* Basic knowledge of Ruby.

## License

Ramaze is licensed under the MIT license, a copy of this license can be found in
``guide/LICENSE``. If you happen to view this README using YARD (this is what
you see on <http://ramaze.net/documentation/index.html>) you can also view this
license by clicking the "Files" button at the top right and then clicking on the
"LICENSE" item.

## Community

* \#ramaze on the Freenode IRC network
* [Mailing list][mailing list]
* [Website][website]

When joining the IRC channel you don't have to be afraid to ask a question, just
ask it and (hopefully) you'll get the answer you're looking for. However, keep
in mind that most of us are located in different timezones so it may sometimes
take a while before you get a reply.

## Chapters

If you're viewing this file in your editor or from Github it's likely that the
table of contents isn't rendered. You can find all these files in the ``guide/``
directory.

* {file:general/installation Installation}
* {file:general/principles Principles}
* {file:general/special_thanks Special Thanks}
* {file:general/contributing Contributing To Ramaze}
* {file:general/configuration Configuration}
* {file:general/ramaze_command Ramaze Command}
* {file:general/controllers Controllers}
* {file:general/models Models}
* {file:general/views Views}
* {file:general/helpers Helpers}
* {file:general/middlewares Rack Middlewares}
* {file:general/routes Routes}
* {file:general/sessions Sessions}
* {file:general/cache Caching Data}
* {file:general/logging Logging Information}
* {file:general/testing Testing Ramaze}

## Tutorials

* {file:tutorials/introduction Introduction Tutorial}

[mailing list]: https://groups.google.com/forum/#!forum/ramaze
[website]: http://ramaze.net/
