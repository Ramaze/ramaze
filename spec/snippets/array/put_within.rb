#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe 'Array' do
  describe '#put_within' do
    it 'puts a given object at a well-described position' do
      array = [:foo, :bar, :baz]
      array.put_within(:foobar, :after => :bar, :before => :baz)
      array.should == [:foo, :bar, :foobar, :baz]
    end

    it 'raises on uncertainity' do
      array = [:foo, :bar, :baz]
      lambda{
        array.put_within(:foobar, :after => :foo, :before => :baz)
      }.should.raise(ArgumentError).
        message.should == "Too many elements within constrain"
    end
  end

  describe '#put_after' do
    it 'puts a given object at a well-described position' do
      array = [:foo, :bar, :baz]
      array.put_after(:bar, :foobar)
      array.should == [:foo, :bar, :foobar, :baz]
    end
  end

  describe '#put_within' do
    it 'puts a given object at a well-described position' do
      array = [:foo, :bar, :baz]
      array.put_before(:bar, :foobar)
      array.should == [:foo, :foobar, :bar, :baz]
    end
  end
end
