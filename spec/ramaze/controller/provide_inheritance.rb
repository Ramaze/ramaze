#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecControllerInheritedMain < Ramaze::Controller
  Ramaze.node('/')

  def index
    @ngr = "Main is nagoro"
    "<p>#{@ngr}</p>"
  end
end

class SpecControllerInheritedOther < Ramaze::Controller
  Ramaze.node('/other').engine(:Haml)
  def index; "%p Other is haml"; end
end

class SpecControllerInheritedAnother < SpecControllerInheritedOther
  Ramaze.node('/another')
  def index; "%p Another is haml. Inherit from Other"; end
end

describe 'Ramaze::Controller#self.inherited' do
  behaves_like :rack_test

  should 'default renders nagoro' do
    get('/').body.should == "<p>Main is nagoro</p>"
  end

  should 'be able to render provided format' do
    get('/other').body.should == "<p>Other is haml</p>\n"
  end

  should "inherit provide from parent controller" do
    get('/another').body.should ==
      "<p>Another is haml. Inherit from Other</p>\n"
  end
end
