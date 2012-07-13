#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecStackHelper < Ramaze::Controller
  map '/'
  helper :stack
  engine :None

  def logged_in_page
    call(r(:login)) unless logged_in?
    "the logged in page"
  end

  def logged_in_params
    call(r(:login)) unless logged_in?
    request.params.inspect
  end

  def secure
    logged_in? ? 'secret content' : 'please login'
  end

  def login
    session[:logged_in] = true
    answer(r(:secure))
  end

  def logout
    session.delete(:logged_in)
  end

  private

  def logged_in?
    session[:logged_in]
  end
end

describe Ramaze::Helper::Stack do
  behaves_like :rack_test
  @uri = 'http://example.org'

  should 'login directly' do
    get('/secure').body.should == 'please login'

    get('/login').status.should == 302
    last_response['Location'].should == "#@uri/secure"

    get('/secure').status.should == 200
    last_response.body.should == 'secret content'

    get('/secure').body.should == 'secret content'
    get('/logout')
    get('/secure').body.should == 'please login'
  end

  should 'login via redirects' do
    get('/logged_in_page').status.should == 302
    last_response['Location'].should == 'http://example.org/login'

    get('/login').status.should == 302
    last_response['Location'].should == 'http://example.org/logged_in_page'

    get('/logged_in_page').status.should == 200
    last_response.body.should == 'the logged in page'

    get('/logout')
    get('/secure').body.should == 'please login'
  end

  should 'login with params via redirects' do
    get('/logged_in_params?x=y').status.should == 302
    last_response['Location'].should == 'http://example.org/login'

    get('/login').status.should == 302
    last_response['Location'].should == 'http://example.org/logged_in_params?x=y'

    get('/logged_in_params?x=y').status.should == 200
    last_response.body.should == {'x' => 'y'}.inspect

    get('/logout')
    get('/secure').body.should == 'please login'
  end
end
