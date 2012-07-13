#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecHelperFlash < Ramaze::Controller
  map '/'
  helper :flash
  trait :flashbox => "%key : %value"

  def box
    flashbox
  end

  def populate_one
    flash[:one] = 'for starters'
  end

  def populate_two
    flash[:one] = 'this one'
    flash[:two] = 'and this'
  end
end

describe Ramaze::Helper::Flash do
  behaves_like :rack_test

  it 'displays a flashbox with one item' do
    get('/populate_one')
    get('/box')
    last_response.status.should == 200
    last_response.body.should == 'one : for starters'
  end

  it 'displays a flashbox with two items' do
    get('/populate_two')
    get('/box')
    last_response.status.should == 200
    last_response.body.split("\n").sort.should == ['one : this one', 'two : and this']
  end
end
