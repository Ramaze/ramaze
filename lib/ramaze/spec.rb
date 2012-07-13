require File.expand_path('../', __FILE__) unless defined?(Ramaze)

Ramaze.deprecated "require('ramaze/spec')", "require('ramaze/spec/bacon')"
require File.expand_path('../spec/bacon', __FILE__)
