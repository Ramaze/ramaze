#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/gestalt'

describe Ramaze::Helper::Gestalt do
  extend Ramaze::Helper::Gestalt

  it 'has a shortcut for Ramaze::Gestalt::new' do
    gestalt{ h1('title') }.to_s.should ==
      Ramaze::Gestalt.new{ h1('title') }.to_s
  end

  it 'has a shortcut for Ramaze::Gestalt::build' do
    build{ h1('title') }.should == '<h1>title</h1>'
  end
end
