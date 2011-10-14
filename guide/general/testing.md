# Testing Ramaze Applications

Ramaze uses and encourages BDD (Behaviour Driven Design). It comes out of the
box with a helper for [Bacon][bacon] gem.

Writing tests with bacon results to clean and complete specifications with minimum
learning time and effort for adaptation.

Check the ``spec`` folder inside your newly generated application for an example.

To run the tests you will need bacon gem installed:

    gem install bacon

Now point to the application spec folder to run bacon:

    bacon spec/*

To test the Ramaze application tests coverage, you can use a tool like [SimpleCov][simplecov]
SimpleCov requires minimum effort to get integrated, start by installing the gem:

    gem install simplecov

Now to reduce the number of changes inside your current files inside ``spec`` folder
you can create a loader like this (named ``init.rb`` here):

    require 'simplecov'
    SimpleCov.start
    MultiJson.engine # Without this `simplecov` can't find json library
    
    # Load the existing files
    Dir.glob('spec/*.rb').each do |spec_file|
      require File.absolute_path(spec_file) unless File.basename(spec_file) == 'init.rb'
    end

Now run bacon on that loader:

    bacon spec/init.rb

SimpleCov on success will create a new directory ``coverage`` with the results.
You can point your browser to the index.html file inside that directory or start
a webserver directly on port 11111 and browse to the same folder.

    python -m SimpleHTTPServer 11111


[bacon]: https://github.com/chneukirchen/bacon
[simplecov]: https://github.com/colszowka/simplecov