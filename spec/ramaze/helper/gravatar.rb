#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/gravatar'

describe Ramaze::Helper::Gravatar do
  extend Ramaze::Helper::Gravatar

  @email = 'ramaze-spec-gravatar@manveru.oib.com'
  @digest = Digest::MD5.hexdigest(@email)

  def uri(*tail)
    URI("http://www.gravatar.com/avatar/#{@digest}#{tail.join}")
  end

  it 'takes an email and turns it into a hashed part of the uri' do
    gravatar(@email).should == uri
  end

  it 'takes :size option' do
    gravatar(@email, :size => 100).should == uri('?size=100')
  end

  it 'takes :rating option' do
    gravatar(@email, :rating => 'g').should == uri('?rating=g')
    gravatar(@email, :rating => 'pg').should == uri('?rating=pg')
    gravatar(@email, :rating => 'r').should == uri('?rating=r')
    gravatar(@email, :rating => 'x').should == uri('?rating=x')
  end

  it 'takes :default option' do
    gravatar(@email, :default => :identicon).should == uri('?default=identicon')
    gravatar(@email, :default => :monsterid).should == uri('?default=monsterid')
    gravatar(@email, :default => :wavatar).should == uri('?default=wavatar')
    gravatar(@email, :default => 'http://example.com/me.jpg').should == uri('?default=http%3A%2F%2Fexample.com%2Fme.jpg')
  end

  it 'takes :force option' do
    gravatar(@email, :force => true).should == uri('?force=1')
    gravatar(@email, :force => false).should == uri('')
  end
end
