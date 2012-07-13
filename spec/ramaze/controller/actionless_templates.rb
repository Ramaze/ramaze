#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

Ramaze::App.options.merge!(:layouts => 'view')

class SpecActionlessTemplates < Ramaze::Controller
  map '/'
  trait :needs_method => true
  alias_view :non_existant_method, :list
end

class SpecActionlessTemplatesLayout < Ramaze::Controller
  map '/other'
  layout 'other_wrapper'
  map_layouts '/'
  trait :needs_method => true

  def index
    "Others Hello"
  end
end

describe "Testing Actionless Templates" do
  behaves_like :rack_test

  it "should not find template file for non existant method" do
    get('/list').status.should == 404
    get('/non_existant_method').status.should == 404
  end

  it "should render layout(without method) for normal action" do
    get('/other').body.should == '<p>Others Hello</p>'
  end
end
