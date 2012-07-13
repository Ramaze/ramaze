#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
require 'dalli'

spec_precondition 'memcached is running' do
  cache = Dalli::Client.new('localhost:11211')
  cache.set('active', true)
end

class SpecSession < Ramaze::Controller
  map '/'
  engine :None

  def index
    'No session here'
  end

  def init
    session[:counter] = 0
  end

  def view
    session[:counter]
  end

  def increment
    session[:counter] += 1
  end

  def decrement
    session[:counter] -= 1
  end

  def reset
    session.clear
  end
end

Ramaze::Cache.options.session = Ramaze::Cache::MemCache

describe 'Sessions with Ramaze::Cache::MemCache' do
  behaves_like :rack_test

  should 'initiate session as needed' do
    get '/'
    last_response.body.should == 'No session here'
    last_response['Set-Cookie'].should == nil

    get('/init')
    last_response.body.should == '0'

    1.upto(10) do |n|
      get('/increment').body.should == n.to_s
    end

    get('/reset')
    get('/view').body.should == ''
    get('/init').body.should == '0'

    -1.downto(-10) do |n|
      get('/decrement').body.should == n.to_s
    end
  end
end
