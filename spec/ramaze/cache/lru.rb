#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

describe Ramaze::Cache::LRU do
  Ramaze.options.cache.names = [:one, :two]
  Ramaze.options.cache.default = Ramaze::Cache::LRU
  Ramaze.setup_dependencies

  cache = Ramaze::Cache.one
  hello = 'Hello, World!'

  should 'store without ttl' do
    cache.store(:hello, hello).should == hello
  end

  should 'fetch' do
    cache.fetch(:hello).should == hello
  end

  should 'delete' do
    cache.delete(:hello)
    cache.fetch(:hello).should == nil
  end

  should 'delete two key/value pairs at once' do
    cache.store(:hello, hello).should == hello
    cache.store(:ramaze, 'ramaze').should == 'ramaze'
    cache.delete(:hello, :ramaze)
    cache.fetch(:hello).should == nil
    cache.fetch(:innate).should == nil
  end

  should 'store with ttl' do
    cache.store(:hello, @hello, :ttl => 0.2)
    cache.fetch(:hello).should == @hello
    sleep 0.3
    cache.fetch(:hello).should == nil
  end

  should 'clear' do
    cache.store(:hello, @hello)
    cache.fetch(:hello).should == @hello
    cache.clear
    cache.fetch(:hello).should == nil
  end
end
