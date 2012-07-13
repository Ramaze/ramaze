# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`
#
# Note that the require 'rubygems' line is only required if you're running a
# Ruby implementation that's based on 1.8 such as REE or Rubinius (although I'm
# not sure if the latter actually requires this).
require 'rubygems'
require 'ramaze'

# This block of code automatically downloads and installs all the specified
# Gems. This is similar to how Bundler and Isolate work but in a much simpler
# way.
Ramaze.setup(:verbose => false) do
  gem 'sequel'
  gem 'sqlite3'
  gem 'bcrypt-ruby', :lib => 'bcrypt'
  gem 'rdiscount'
end

# Make sure that Ramaze knows where you are. Without this layouts and such
# wouldn't be rendered. While Ramaze.options.roots includes "." (the current
# directory) you should not rely on this path as it changes depending from what
# directory this script was called.
Ramaze.options.roots = [__DIR__]

# Initialize controllers and models
require __DIR__('model/init')
require __DIR__('controller/init')

Ramaze::Log.info('Logging in can be done by going to /users/login')
