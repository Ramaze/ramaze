#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecAction < Ramaze::Controller
  map '/'
  provide :html, :None

  def index
    'Hello, World!'
  end

  def bar
    "yo from bar"
  end
end

describe 'Action#render' do
  it 'works when Action is manually created' do
    action = SpecAction.resolve('/')
    action.render.should == 'Hello, World!'
  end
end
