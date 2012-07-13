#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.
require 'innate/helper'

module Ramaze
  Helper = Innate::Helper
  Innate::HelpersHelper.options.paths << File.dirname(__FILE__)

  require 'ramaze/helper/flash'
  require 'ramaze/helper/link'
  require 'ramaze/helper/layout'
end
