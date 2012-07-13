#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecHelperCache < Ramaze::Controller
  map '/'
  helper :cache

  cache_action(:method => :cached_action)
  cache_action(:method => :with_params)
  cache_action(:method => :with_type)

  def cached_value
    cache_value[:time] ||= random
  end

  def cached_action
    random.to_s
  end

  def with_params(foo, bar)
    "foo: #{foo}, bar: #{bar}, random: #{random}"
  end

  def with_type
    response['Content-Type'] = 'text/plain'
    random.to_s
  end

  private

  def random
    [Time.now.usec, rand].inspect
  end
end

class SpecHelperCacheTTL < Ramaze::Controller
  map '/ttl'
  helper :cache
  cache_action(:method => :index, :ttl => 1)

  def index
    rand.to_s
  end
end

class SpecHelperCacheKey < Ramaze::Controller
  map '/key'
  helper :cache
  cache_action(:method => :index){ request[:name] }

  def index
    "hi #{request['name']} #{rand}"
  end
end

describe Ramaze::Helper::Cache do
  behaves_like :rack_test

  it 'caches actions' do
    got = get('/cached_action')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should.not.be.empty

    cached_body = got.body

    got = get('/cached_action')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should == cached_body
  end

  it 'caches values' do
    got = get('/cached_value')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should.not.be.empty

    cached_body = got.body

    got = get('/cached_value')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should == cached_body
  end

  it 'caches actions with params' do
    2.times do
      lambda{ get('/with_params/foo/bar').body }.should.not.change{ get('/with_params/foo/bar').body }
    end

    get('/with_params/foo/bar').body.should.not == get('/with_params/baz/quux').body
  end

  it 'preserves the Content-Type' do
    2.times do
      lambda{ get('/with_type').body }.should.not.change{ get('/with_type').body }
    end

    get('/with_type')['Content-Type'].should == 'text/plain'
  end

  it 'caches actions with ttl' do
    2.times do
      lambda{ get('/ttl').body }.should.not.change{ get('/ttl').body }
    end

    lambda{ sleep 1.5; get('/ttl').body }.should.change{ get('/ttl').body }
  end

  it 'caches actions with block keys' do
    2.times do
      lambda{ get('/key?name=foo').body }.should.not.change{ get('/key?name=foo').body }
    end

    get('/key?name=foo').body.should.not == get('/key?name=bar').body
  end

  it 'caches actions on a per-controller basis' do
    get('/ttl').body.should.not == get('/key').body
  end
end
