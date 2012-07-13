#!/usr/bin/env ruby

# Use this file directly like `ruby start.rb` if you don't want to use the
# `ramaze start` command.
#
# All application related things should go into `app.rb`, this file is simply
# for options related to running the application locally.
#
# You can run this file as following:
#
#  $ ruby start.rb
#  $ ./start.rb
#
# If you want to be able to do the latter you'll have to make sure the file can be
# executed:
#
#  $ chmod +x ./start.rb
require File.expand_path('../app', __FILE__)

Ramaze.start(:adapter => :webrick, :port => 7000, :file => __FILE__)
