require 'rubygems'
require 'ramaze'

$wikore = {}

require_relative 'src/model'
require_relative 'src/controller'

Ramaze.start :file => __FILE__
