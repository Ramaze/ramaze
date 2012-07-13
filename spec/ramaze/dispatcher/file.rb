#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

# This spec more or less tries to ensure that we integrate with rack and
# rack-contrib in regards to static file serving.

spec_require 'rack/contrib'

# minimal middleware, no exception handling
Ramaze.middleware!(:spec) do |m|
  m.apps Rack::ConditionalGet, Rack::ETag
  m.run Ramaze::AppMap
end

class Main < Ramaze::Controller
  map '/'
  def index
    "nothing"
  end
end

describe 'Serving static files' do
  behaves_like :rack_test

  it 'serves from public root' do
    css = File.read(__DIR__('public/test_download.css'))
    get '/test_download.css'
    last_response.body.should   === css
    last_response.status.should === 200
  end

  it 'serves files with spaces' do
    get '/file%20name.txt'
    last_response.status.should === 200
    last_response.body.should   === 'hi'
  end

  it 'sends ETag for string bodies' do
    get '/'
    last_response['ETag'].size.should > 1
  end

  it 'sends Last-Modified for file bodies' do
    get '/test_download.css'

    mtime = File.mtime(__DIR__('public/test_download.css'))

    last_response['Last-Modified'].should == mtime.httpdate
  end

  it 'respects ETag with IF_NONE_MATCH' do
    get '/'

    etag = last_response['ETag']
    etag.should.not.be.nil

    header 'IF_NONE_MATCH', etag
    get '/'

    last_response.status.should === 304
    last_response.body.should   === ''
  end

  it 'respects Last-Modified with IF_MODIFIED_SINCE' do
    get '/test_download.css'

    mtime = last_response['Last-Modified']

    mtime.nil?.should === false

    header 'IF_NONE_MATCH'    , nil
    header 'IF_MODIFIED_SINCE', mtime
    get '/test_download.css'

    last_response.status.should === 304
    last_response.body.should   === ''
  end
end
