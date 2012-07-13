#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class BaseController < Ramaze::Controller
  alias_view :foo, :bar
  alias_view :one, :another, self

  def test() 'test' end
end

class MainController < BaseController
end

describe 'Controller' do
  behaves_like :rack_test

  it 'allows sub-classing MainController' do
    get('/test').body.should == 'test'
  end

  it 'respects view aliase from superclass, with no explicit controller' do
    # The template file it should use is view/bar.xhtml, as the template
    # mapping doesn't specify a controller, so it will be implicitly relative
    # to MainController.
    get('/foo').body.should == 'bar'
  end

  it 'respects view aliase from superclass, with an explicit controller' do
    # Note that the template file it should use is view/base/another.xhtml,
    # because BaseController explicitly specifies the template mapping in
    # relation to self.
    get('/one').body.should == 'another'
  end
end
