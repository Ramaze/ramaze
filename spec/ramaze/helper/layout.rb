#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class LayoutHelperOne < Ramaze::Controller
  map '/one'

  set_layout 'default'

  def laid_out1; end
  def laid_out2; end
  def laid_out3; end
end

class LayoutHelperTwo < Ramaze::Controller
  map '/two'

  layout     'default'
  set_layout 'alternative' => [:laid_out2, :laid_out3]

  def laid_out1; end
  def laid_out2; end
  def laid_out3; end
end

class LayoutHelperThree < Ramaze::Controller
  map '/three'

  set_layout 'default' => [:laid_out1], 'alternative' => [:laid_out2]
  set_layout 'default' => [:laid_out3]

  def laid_out1; end
  def laid_out2; end
  def laid_out3; end
end

class LayoutHelperFour < Ramaze::Controller
  map '/four'

  layout { |path| 'default' }

  set_layout 'alternative' => [:laid_out2]
  set_layout 'alternative' => [:laid_out3]

  def laid_out1; end
  def laid_out2; end
  def laid_out3; end
end

describe Ramaze::Helper::Layout do
  behaves_like :rack_test

  it 'lays out all actions' do
    get '/one/laid_out1'
    last_response.status.should == 200
    last_response.body.should.match /laid out/

    get '/one/laid_out2'
    last_response.status.should == 200
    last_response.body.should.match /laid out/

    get '/one/laid_out3'
    last_response.status.should == 200
    last_response.body.should.match /laid out/
  end

  it 'lays out only a whitelist of actions with layout() as a fallback' do
    get '/two/laid_out1'
    last_response.status.should == 200
    last_response.body.should.match /laid out/

    get '/two/laid_out2'
    last_response.status.should == 200
    last_response.body.should.match /alternative/

    get '/two/laid_out3'
    last_response.status.should == 200
    last_response.body.should.match /alternative/
  end

  it 'Define a set of method specific layouts' do
    get '/three/laid_out1'
    last_response.status.should === 200
    last_response.body.should.match /laid out/

    get '/three/laid_out2'
    last_response.status.should === 200
    last_response.body.should.match /alternative/

    get '/three/laid_out3'
    last_response.status.should === 200
    last_response.body.should.match /laid out/
  end

  it 'lays out a whitelist with layout() as a fallback using a block' do
    get '/four/laid_out1'
    last_response.status.should == 200
    last_response.body.should.match /laid out/

    get '/four/laid_out2'
    last_response.status.should == 200
    last_response.body.should.match /alternative/

    get '/four/laid_out3'
    last_response.status.should == 200
    last_response.body.should.match /alternative/
  end
end
