#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/spec/helper/template_examples'

spec_require 'tenjin'
require File.expand_path('../../../../examples/templates/template_tenjin', __FILE__)

describe 'Template Tenjin' do
  behaves_like :template_spec
  spec_template 'Tenjin'
end
