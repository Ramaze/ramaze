#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'ramaze/gestalt'

Ramaze::App.options.views = 'gestalt'

class SpecGestalt < Ramaze::Controller
  map '/'
  engine :Gestalt
  helper :gestalt

  def index
    @title = 'Gestalt Index'
    g
  end

  def links
    g
  end

  def with_partial
    g
  end

  def different_module
    g(:foo, SpecGestalDifferentModule)
  end
end

module SpecGestaltView
  def index
    h1 @title
  end

  def links
    ul do
      li{ a "Index page",        :href => rs(:index)    }
      li{ a "Internal template", :href => rs(:internal) }
      li{ a "External template", :href => rs(:external) }
    end
  end

  # def external
  #   ol do
  #     3.times{ render_view('template') }
  #   end
  # end

  def with_partial
    ul do
      3.times{ _partial }
    end
  end

  def _partial
    li 'List Item'
  end
end

module SpecGestalDifferentModule
  def foo
    p{ 'view module specified'}
  end
end

describe Ramaze::View::Gestalt do
  behaves_like :rack_test

  should 'use g helper' do
     get('/').body.should == '<h1>Gestalt Index</h1>'
   end

  should 'use other helper methods' do
    get('/links').body.should ==
      '<ul><li><a href="/index">Index page</a></li><li><a href="/internal">Internal template</a></li><li><a href="/external">External template</a></li></ul>'
  end

  should 'render external template' do
     get('/external').body.should ==
      "<html><head><title>Gestalt Test</title></head><body><h1>Gestalt Template</h1></body></html>"
  end

  should 'use method like partials' do
    get('/with_partial').body.should ==
      '<ul><li>List Item</li><li>List Item</li><li>List Item</li></ul>'
  end

  should 'be able to specify different view module and method' do
    get('/different_module').body.should ==
      '<p>view module specified</p>'
  end
end
