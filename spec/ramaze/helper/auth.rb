#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

$password = Digest::SHA1.hexdigest('pass')

class SpecHelperAuth < Ramaze::Controller
  map '/'
  helper :auth

  def index
    self.class.name
  end

  def session_inspect
    session.inspect
  end

  def secured
    "Secret content"
  end

  before(:secured) { login_required }
end

class SpecHelperAuthHash < SpecHelperAuth
  map '/hash'
  trait :auth_table => {
      'manveru' => $password
    }
end

class SpecHelperAuthMethod < SpecHelperAuth
  map '/method'
  trait :auth_table => :auth_table

  private

  def auth_table
    { 'manveru' => $password }
  end
end

class SpecHelperAuthLambda < SpecHelperAuth
  map '/lambda'
  trait :auth_table => lambda {
    { 'manveru' => $password }
  }
end

describe Ramaze::Helper::Auth do
  %w[ hash lambda method ].each do |prefix|
    describe "login" do
      behaves_like :rack_test

      it "uses a #{prefix}" do
        get "/#{prefix}/secured"
        follow_redirect!
        last_response.status.should == 200
        last_response.body.should   =~ (/<form/)

        post("/#{prefix}/login", 'username' => 'manveru', 'password' => 'pass')
        follow_redirect!
        last_response.status.should == 200
        last_response.body.should   == 'Secret content'

        get "/#{prefix}/secured"
        last_response.status.should == 200
        last_response.body.should   == 'Secret content'

        get "/#{prefix}/logout"
        follow_redirect!
        last_response.status.should == 200
        last_response.body.should   == 'SpecHelperAuth'

        get "/#{prefix}/secured"
        follow_redirect!
        last_response.status.should == 200
        last_response.body.should   =~ (/<form/)
      end
    end
  end
end
