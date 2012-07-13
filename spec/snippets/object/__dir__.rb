#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe '__DIR__' do
  # this is hardly exhaustive, but better than nothing
  it 'should report the directory of the current file' do
    __DIR__.should == File.dirname(File.expand_path(__FILE__))
  end

  should 'join passed arguments and prefix with directory of current file' do
    __DIR__(:foo).should == File.join(File.dirname(File.expand_path(__FILE__)), 'foo')
    __DIR__('foo/bar').should == File.join(File.dirname(File.expand_path(__FILE__)), 'foo/bar')
    __DIR__(:foo, :bar).should == File.join(File.dirname(File.expand_path(__FILE__)), 'foo/bar')
  end
end
