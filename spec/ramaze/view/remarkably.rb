#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'remarkably'

Ramaze::App.options.views = 'remarkably'

class SpecRemarkably < Ramaze::Controller
  map '/'
  engine :Remarkably
  helper :remarkably

  def index
    h1 "Remarkably Index"
  end

  def links
    ul do
      li { a "Index page", :href => r(:index) }
      li { a "Internal template", :href => r(:internal) }
      li { a "External template", :href => r(:external) }
    end
  end

  def sum(num1, num2)
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

describe Ramaze::View::Remarkably do
  behaves_like :rack_test

  should 'use remarkably methods' do
    get('/').body.should == '<h1>Remarkably Index</h1>'
  end

  should 'use other helper methods' do
    get('/links').body.should == '<ul><li><a href="/index">Index page</a></li><li><a href="/internal">Internal template</a></li><li><a href="/external">External template</a></li></ul>'
  end

  should 'render external template' do
    get('/external').body.should == "<html><head><title>Remarkably Test</title></head><body><h1>Remarkably Template</h1></body></html>"
  end

  should 'render external template with instance variables' do
    get('/sum/1/2').body.should == '<div>3</div>'
  end
end
