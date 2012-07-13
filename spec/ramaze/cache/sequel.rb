#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'sequel'

DB = Sequel.sqlite(':memory:')

describe Ramaze::Cache::Sequel do
  Ramaze.options.cache.names = [:one, :two]
  Ramaze.options.cache.default = Ramaze::Cache::Sequel
  Ramaze.setup_dependencies

  cache = Ramaze::Cache.one
  hello = 'Hello, World!'

  should 'Store some data without a TTL' do
    cache.store(:hello, hello).should.equal hello
  end

  should 'Fetch a cache item' do
    cache.fetch(:hello).should.equal hello
  end

  should 'Delete a cache item' do
    cache.delete(:hello)
    cache.fetch(:hello).should == nil
  end

  should 'Delete two key/value pairs at once' do
    cache.store(:hello, hello).should.equal hello
    cache.store(:ramaze, 'ramaze').should.equal 'ramaze'
    cache.delete(:hello, :ramaze)
    cache.fetch(:hello).should.equal nil
    cache.fetch(:innate).should.equal nil
  end

  should 'Store some data with a TTL' do
    cache.store(:hello, @hello, :ttl => 1)
    cache.fetch(:hello).should.equal @hello
    sleep 2
    cache.fetch(:hello).should.equal nil
  end

  should 'Clear the cache' do
    cache.store(:hello, @hello)
    cache.fetch(:hello).should.equal @hello
    cache.clear
    cache.fetch(:hello).should.equal nil
  end

  should 'use a custom set of options' do
    klass = Ramaze::Cache::Sequel.using(:answer => 42)

    klass.options[:answer].should     === 42
    klass.new.options[:answer].should === 42
  end
end
