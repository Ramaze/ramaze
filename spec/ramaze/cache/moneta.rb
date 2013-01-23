require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'moneta'

describe Ramaze::Cache::Moneta do
  Ramaze.options.cache.names   = [:one, :two]
  Ramaze.options.cache.default = Ramaze::Cache::Moneta
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
    cache.store(:hello, @hello, :ttl => 1)
    cache.fetch(:hello).should == @hello
    sleep 2
    cache.fetch(:hello).should == nil
  end

  should 'clear' do
    cache.store(:hello, @hello)
    cache.fetch(:hello).should == @hello
    cache.clear
    cache.fetch(:hello).should == nil
  end

  should 'use a custom set of options' do
    klass = Ramaze::Cache::Moneta.using(:answer => 42)

    klass.options[:answer].should     == 42
    klass.new.options[:answer].should == 42
  end
end
