# Installation

Ramaze can be installed by using [Rubygems][rubygems], direct download or by
using Git. Installing Ramaze via Rubygems only needs a single command:

    $ gem install ramaze

Optionally you can specify ``-v`` to install a specific version:

    $ gem install ramaze -v 2011.07.25

## Git

If you're interested in hacking on Ramaze or you just want to browse the source
you can use Git to install a local copy of Ramaze. For this you'll need to have
Git installed (refer to your package manager for details on installing Git).
When installed you can clone the Ramaze repository with the following commnad:

    $ git clone git://github.com/ramaze/ramaze.git

Once the cloning process has completed you should ``cd`` into the directory to
install all required gems and optionally set up an RVM environment in case
you're using RVM:

    $ cd ramaze
    $ rake setup

Once installed you can build a gem manually or just require the local
installation manually:

    require '/path/to/ramaze/lib/ramaze'

Building a gem can be done using the command ``rake gem:build``, if you want to
also install the gem after it's built you should run ``rake gem:install``
instead.

Another way of loading Ramaze is to add it to your ``$RUBYLIB`` variable. It's
best if you put this in your ``.bashrc`` file so that you don't have to run the
command manually every time you open up a new terminal:

    export RUBYLIB="/path/to/ramaze/lib"

This approach allows you to load Ramaze like you'd normally would instead of
having to specify the full path.

## Direct Download

In case you don't have Git installed but still want to have a local copy you can
download a tarball from Github. If you want to download the latest copy you can
go to the [Downloads][downloads] page, if you want to download a specific tag
instead you should navigate to the [Tags][tags] page.

Once downloaded and extracted the setup process is the same as when installing
Ramaze via Git.

[rubygems]: http://rubygems.org/
[downloads]: https://github.com/Ramaze/ramaze/downloads
[tags]: https://github.com/Ramaze/ramaze/tags
