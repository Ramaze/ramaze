#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../spec/helper', __FILE__)

module Ramaze
  module View
    module MyEngine
      def self.call(action, string)
        return string, 'application/x-ruby'
      end
    end

    register View::MyEngine.name, :my
  end
end

class SpecView < Ramaze::Controller
  map '/'
  engine :MyEngine

  def index
    'Hello, World!'
  end
end

describe Ramaze::View do
  behaves_like :rack_test

  it 'uses MyEngine' do
    got = get('/')
    got.status.should == 200
    got['Content-Type'].should == 'application/x-ruby'
    got.body.should == 'Hello, World!'
  end
end
