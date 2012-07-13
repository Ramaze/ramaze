#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe 'Thread.into' do
  it 'should provide access to thread vars' do
    Thread.current[:foo] = :bar
    Thread.new{ Thread.current[:foo].should == nil }.join
    Thread.into{ Thread.current[:foo].should == :bar }.join
  end
end
