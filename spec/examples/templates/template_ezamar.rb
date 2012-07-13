#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/spec/helper/template_examples'

spec_require 'ezamar'
require File.expand_path('../../../../examples/templates/template_ezamar', __FILE__)

describe 'Template Ezamar' do
  behaves_like :template_spec
  spec_template 'Ezamar'
end
