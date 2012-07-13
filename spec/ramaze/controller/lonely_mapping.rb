#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecHello < Ramaze::Controller
  def index
    'automatically mapped'
  end
end

describe 'Lonely Controller automap' do
  behaves_like :rack_test

  it 'automatically creates an app and maps the controller into it' do
    get('/').body.should == 'automatically mapped'
  end
end
