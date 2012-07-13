#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'maruku'

class SpecHelperMaruku < Ramaze::Controller
  map '/'
  helper :maruku

  def index
    maruku('# Hello')
  end
end

describe Ramaze::Helper::Maruku do
  behaves_like :rack_test

  it 'converts a markdown string to html' do
    get('/').body.should =~ /<h1 id=["']hello["']>Hello<\/h1>/
  end
end
