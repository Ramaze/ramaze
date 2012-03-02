# Helpers

Helpers are simple modules that can be used in controllers to prevent developers
from having to write the same code over and over again. There's no actual
definition of how helpers should be used and what they should do but the general
idea is quite simple, all logic that may be shared among controllers should go
in a helper. For example, Ramaze ships with it's own layout helper that adds a
method ``set_layout()`` (see the {file:general/views Views} chapter).

In order to use a helper there are a few guidelines it should follow. The most
important guideline (or rule) is that it should be declared under the
Ramaze::Helper namespace. Say your helper is called "Cake" this would result in
Ramaze::Helper::Cake as the full name. The second rule/guideline is that helpers
should be placed in the "helper" directory of your Ramaze application (or any
other directory added to the list of helper paths). This is required in order to
load helpers the ramaze way, otherwise you'll have to manually load each helper.

## Loading Helpers

Loading helpers the Ramaze way is pretty easy and can be done using the method
helper():

    class Blogs < Ramaze::Controller
      helper :cake
    end

This method can load multiple helpers in a single call as well:

      class Blogs < Ramaze::Controller
        helper :cake, :pie, :candy
      end

If you have your helper located somewhere else or don't want to use the helper()
method you can just include each helper the regular way:

    class Blogs < Ramaze::Controller
      include Ramaze::Helper::Cake
      include Ramaze::Helper::Pie
      include Ramaze::Helper::Candy
    end

As you can see this requires more lines of code and thus it's recommended to
load all helpers the Ramaze way.

## Available Helpers

* {Ramaze::Helper::Auth}: basic authentication without a model.
* {Ramaze::Helper::Bench}: basic benchmarking of your code.
* {Ramaze::Helper::BlueForm}: makes building forms fun again.
* {Ramaze::Helper::Cache}: caching of entire actions and custom values in your
  controllers.
* {Ramaze::Helper::CSRF}: protect your controllers from CSRF attacks.
* {Ramaze::Helper::Disqus}
* {Ramaze::Helper::Email}: quick and easy way to send Emails.
* {Ramaze::Helper::Erector}
* {Ramaze::Helper::Flash}
* {Ramaze::Helper::Gestalt}: helper for {Ramaze::Gestalt}.
* {Ramaze::Helper::Gravatar}: easily generate Gravatars.
* {Ramaze::Helper::Identity}: helper for OpenID authentication.
* {Ramaze::Helper::Layout}: easily set layouts for specific actions.
* {Ramaze::Helper::Link}
* {Ramaze::Helper::Localize}
* {Ramaze::Helper::Markaby}
* {Ramaze::Helper::Maruku}
* {Ramaze::Helper::Paginate}: easily paginate rows of data.
* {Ramaze::Helper::Remarkably}
* {Ramaze::Helper::RequestAccessor}
* {Ramaze::Helper::SendFile}
* {Ramaze::Helper::SimpleCaptcha}: captches using simple mathematical questions.
* {Ramaze::Helper::Stack}
* {Ramaze::Helper::Tagz}
* {Ramaze::Helper::Thread}
* {Ramaze::Helper::Ultraviolet}
* {Ramaze::Helper::Upload}: uploading files made easy.
* {Ramaze::Helper::UserHelper}: authenticate users using a model.
* {Ramaze::Helper::XHTML}

## Innate Helpers

Note that you may also find some popular helpers, that are used by default in 
Ramaze, under the Innate project.

* {Innate::Helper::Aspect}: provides before/after wrappers for actions.
* {Innate::Helper::CGI}: gives shortcuts to some CGI methods.
* {Innate::Helper::Flash}: gives simple access to session.flash. 
* {Innate::Helper::Link}: provides the path to a given Node and action.
* {Innate::Helper::Redirect}: provides the request redirect, raw_redirect 
and respond convenience methods. 
* {Innate::Helper::Render}: provides variants for partial, custom, full 
view rendering.
