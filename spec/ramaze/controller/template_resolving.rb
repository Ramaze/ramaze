#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecViewAlias < Ramaze::Controller
  map '/'

  def greet(type, message = "Message")
    @greet = "#{type} : #{message}"
  end

  def list
    @obj = Ramaze::Current.action.method
  end

  alias_method :index, :list
  alias_view :index, :list
  alias_view :non_existant_method, :list
end

class SpecViewAlias2 < SpecViewAlias
  map '/other'

  def greet__mom(message = "Moms are cool!")
    greet('Mom', message)
  end
  alias_view :greet__mom, :greet, SpecViewAlias

  def greet__other
    @greet = "Other"
  end
  alias_view :greet__other, :blah

  def greet__another
    @greet = "Another"
  end
  alias_view :greet__another, :greet__other

  def greet__last
    @greet = 'Last'
  end
  alias_view :greet__last, 'greet__other'
end

describe "Template aliasing" do
  behaves_like :rack_test

  it 'serves normal template' do
    get('/greet/asdf').body.should == '<html>asdf : Message</html>'
  end

  it 'references template from another controller' do
    get('/other/greet/mom').body.should == '<html>Mom : Moms are cool!</html>'
  end

  it 'only uses aliased template if one can be found' do
    get('/other/greet/other').body.should == '<html>Other: Other</html>'
  end

  it 'accepts aliases given as symbols' do
    get('/other/greet/another').body.should == '<html>Other: Another</html>'
  end

  it 'accepts aliases given as strings' do
    get('/other/greet/last').body.should == '<html>Other: Last</html>'
  end

  it 'aliases template for index action' do
    get('/list').body.should == '<html>list</html>'
    get('/index').body.should == '<html>index</html>'
  end

  it 'uses aliases even for non-existant actions' do
    get('/non_existant_method').body.should == '<html></html>'
  end
end
