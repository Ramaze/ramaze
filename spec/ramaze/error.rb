#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../spec/helper', __FILE__)
require 'nokogiri'

class SpecError < Ramaze::Controller
  map '/'

  def raises
    blah
  end

  def empty
    response.status = 404
    ''
  end
end

class SpecErrorHandling < SpecError
  map '/handle'

  def self.action_missing(path)
    try_resolve("/not_found")
  end

  def not_found
    "Sorry, this document doesn't exist"
  end

  def name_error
    "Sorry, this name doesn't exist"
  end
end

describe 'Error handling' do
  behaves_like :rack_test

  Ramaze.options.mode = :dev

  it 'uses Rack::ShowException to display errors' do
    got = get('/raises', {}, {'HTTP_ACCEPT' => 'text/html'})
    got.status.should == 500
    got['Content-Type'].should == 'text/html'

    doc = Nokogiri::HTML(got.body)
    doc.at("#summary").text.should.match(/NameError at \/raises/)
    doc.at("#explanation").text.strip.should ==
      "You're seeing this error because you use Rack::ShowExceptions."
  end

  it 'uses original action_missing when no action was found' do
    got = get('/missing')
    [got.status, got['Content-Type']].should == [404, 'text/plain']

    got.body.should == 'No action found at: "/missing"'
  end

  it 'uses custom action_missing when no action was found' do
    got = get('/handle/mssing')
    [got.status, got['Content-Type']].should == [200, 'text/html']

    got.body.should == "Sorry, this document doesn't exist"
  end

  it 'uses Rack::RouteExceptions when a route is set' do
    Rack::RouteExceptions.route(NameError, '/handle/name_error')

    got = get('/raises')
    [got.status, got['Content-Type']].should == [200, 'text/html']

    got.body.should == "Sorry, this name doesn't exist"
  end

  it 'uses Rack::ShowStatus for empty responses > 400' do
    got = get('/empty')
    [got.status, got['Content-Type']].should == [404, 'text/html']

    doc = Nokogiri::HTML(got.body)
    doc.at("#info").text.strip.should == "Not Found"
    doc.at("#explanation").text.strip.should ==
      "You're seeing this error because you use Rack::ShowStatus."
  end
end
