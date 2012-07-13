#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../spec/helper', __FILE__)

describe 'Ramaze::Request' do
  def request(env = {})
    Ramaze::Request.new(env)
  end

  @env = {
    "GATEWAY_INTERFACE"    => "CGI/1.1",
    "HTTP_ACCEPT"          => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "HTTP_ACCEPT_CHARSET"  => "UTF-8,*",
    "HTTP_ACCEPT_ENCODING" => "gzip,deflate",
    "HTTP_ACCEPT_LANGUAGE" => "en-us,en;q=0.8,de-at;q=0.5,de;q=0.3",
    "HTTP_CACHE_CONTROL"   => "max-age=0",
    "HTTP_CONNECTION"      => "keep-alive",
    "HTTP_HOST"            => "localhost:7000",
    "HTTP_KEEP_ALIVE"      => "300",
    "HTTP_USER_AGENT"      => "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.5) Gecko/2008123017 Firefox/3.0.4 Ubiquity/0.1.4",
    "HTTP_VERSION"         => "HTTP/1.1",
    "PATH_INFO"            => "/",
    "QUERY_STRING"         => "a=b",
    "REMOTE_ADDR"          => "127.0.0.1",
    "REMOTE_HOST"          => "delta.local",
    "REQUEST_METHOD"       => "GET",
    "REQUEST_PATH"         => "/",
    "REQUEST_URI"          => "http://localhost:7000/",
    "SCRIPT_NAME"          => "",
    "SERVER_NAME"          => "localhost",
    "SERVER_PORT"          => "7000",
    "SERVER_PROTOCOL"      => "HTTP/1.1",
  }

  should 'provide #accept_language' do
    request(@env).accept_language.should == %w[en-us en de-at de]
  end

  should 'provide #http_variables' do
    keys = %w[ HTTP_CACHE_CONTROL HTTP_HOST HTTP_KEEP_ALIVE HTTP_USER_AGENT
               HTTP_VERSION PATH_INFO QUERY_STRING REMOTE_ADDR REMOTE_HOST
               REQUEST_METHOD REQUEST_PATH REQUEST_URI ]
    vars = request(@env).http_variables
    vars.keys.sort.should == keys
    vars.values_at(*keys).should == @env.values_at(*keys)
  end

  should 'provide #accept_charset' do
    request(@env).accept_charset.should == 'UTF-8'
  end

  should 'properly parse requested locale' do
    header = { "HTTP_ACCEPT_LANGUAGE" => "sv-se,sv;q=0.8,en-us;q=0.5,en;q=0.3" }
    request(@env.merge(header)).accept_language_with_weight.should == [
      ['sv-se', 1.0], ['sv', 0.8], ['en-us', 0.5], ['en', 0.3]
    ]

    header = { "HTTP_ACCEPT_LANGUAGE" => "nl-nl" }
    request(@env.merge(header)).accept_language_with_weight.should == [
      ['nl-nl', 1.0]
    ]
  end
end
