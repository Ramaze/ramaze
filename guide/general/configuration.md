# @title Configuration
# Configuration

Ramaze provides two ways of setting configuration options, using
``Ramaze::Optioned`` and ``Ramaze::Traited``.

Both Ramaze::Optioned and Ramaze::Traited are aliases for Innate::Optioned and
Innate::Traited respectively.

## Traits using Ramaze::Traited

Traits provide a way of setting configuration options in a class similar to
class variables. The advantage of using traits is that they are inherited in
classes which allows you to use different values for a trait in a parent and
child class. On top of that you can access traits outside of a class' scope
(class variables are private). Ramaze uses traits for various configuration
settings that are specific to a certain class' instance or module.
``Ramaze::Optioned`` can't be used for this since the options set would be the
same for all instances whereas traits can have their own values.

Using traits is quite simple and can be done by including the module
Ramaze::Traited into your class:

    class Something
      include Ramaze::Traited
    end

This module can be included into controllers, models or any other class. Once
this module has been included into a class you can define a trait using the
method ``trait()``. This method takes a hash where the key is the name of the
trait and the value the value for that trait:

    class Something
      include Ramaze::Traited

      trait :language => 'ruby'
    end

Inside a class instance traits can also be retrieved using this method by simply
specifying the name of the trait:

    class Something
      include Ramaze::Traited

      trait :language => 'ruby'

      def language
        puts "Language: #{trait[:language]}"
      end
    end

Outside of a class' instance you can still retrieve a trait but you need to call
``class_trait()`` instead:

    Something.class_trait[:language] # => "ruby"

Another cool feature of ``Ramaze::Traited`` is that you can get a list of all
traits of a class and all it's parent classes using ``ancestral_trait()``. This
method retrieves all traits where each trait that's redefined will overwrite the
existing one. Example:

    class Foo
      include Ramaze::Traited
      trait :one => :eins, :first => :erstes
    end

    class Bar < Foo
      trait :two => :zwei
    end

    class Foobar < Bar
      trait :three => :drei, :first => :overwritten
    end

    Foobar.ancestral_trait
    # => {:three => :drei, :two => :zwei, :one => :eins, :first => :overwritten}

## Options using Ramaze::Optioned

Ramaze::Optioned can be used to set global options regardless of the instance of
a class. Options set using this module are also inherited but you can't set
different values for different instances. A good use case for Ramaze::Optioned
is the helper ``Ramaze::Helper::Email``. This helper specifies certain options
such as the SMTP host and username. These options don't change in a request or
in an instance of a controller so using traits would be useless. It's also quite
rare that you want to use different settings in a sub controller.

Settings options using Ramaze::Optioned works a bit different compared to traits
but don't worry, it's very easy. First you must include the module and then call
``options.dsl()`` as shown below.

    class Something
      include Ramaze::Optioned

      options.dsl do

      end
    end

Inside the block passed to ``options.dsl()`` you can call the ``option`` method
(aliased as ``o`` so you have to write less code). This method has the following
syntax:

    option(description, name, default value)

Say we want to define a option that allows the user to change a username, this
can be done as following:

    class Something
      include Ramaze::Optioned

      options.dsl do
        o 'Defines the username', :username, 'ramaze'
      end
    end

Once an option is set it can be retrieved by calling ``options`` on the class
(regardless of whether or not the call was made inside an instance):

    # Outside of the class
    Something.options.username # => "ramaze"

    # Inside the class
    options.username # => "ramaze"

Dumping the entire options object to the command line using ``puts`` (or
something similar) will also show the description of each option, the default
value, etc:

    Something.options # => {:username=>{:doc=>"Defines the username", :value=>"ramaze"}}

## Configuring Paths

While Ramaze is a very flexible framework it requires some basic information
about the location of your views, layouts and so on. Ramaze does not
automatically try to locate these but instead uses a set of defined locations
to look for. These paths are set using ``Ramaze::Optioned`` and can be found in
the following options:

* Ramaze.options.views
* Ramaze.options.publics
* Ramaze.options.layouts
* Ramaze.options.roots

Helpers aren't defined in these paths as they're considered a separate part of
Ramaze. Instead of using ``Ramaze.options`` you'll have to update
``Ramaze::HelpersHelper.options.paths``.

Note that ``Ramaze.options.roots`` and ``Ramaze::HelpersHelper.options.paths``
are the only two options that use absolute paths, all other paths are relative
to the root directories.

Let's say you want to have an extra view directory called "templates", this
directory can be added as following:

    Ramaze.options.views.push('templates')

If the "templates" directory is located a level above the application root you'd
do the following instead:

    Ramaze.options.views.push('../templates')

As mentioned before the root directories are absolute, this means that if you
want to add a root directory you have to specify the full path to it:

    Ramaze.options.roots.push('/path/to/another/root/directory')

Technically you can specify relative paths but this might lead to unexpected
behavior so it's not recommended.
