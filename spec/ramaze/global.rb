#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

context "Ramaze::Global" do
  specify "just simple assignment and retrive" do
    Ramaze::Global.some = :xxx
    Ramaze::Global.some.should == :xxx
  end

  specify "setup" do
    Ramaze::Global.setup :a => :b
    Ramaze::Global.a.should == :b
    Ramaze::Global.some.should == :xxx
    Ramaze::Global.setup :a => :c
    Ramaze::Global.a.should == :c
  end

  specify "more neat stuff" do
    Ramaze::Global.update :a => :d, :foo => :bar
    Ramaze::Global.a.should == :c
    Ramaze::Global.foo.should == :bar
  end

  specify "values_at" do
    Ramaze::Global.values_at(:a, :foo).should == [:c, :bar]
  end

  specify "getting thready" do
    Ramaze::Global[:i] = 0
    Thread.main[:i] = 0

    (1..10).each do |i|
      Thread.new do
        Ramaze::Global[:i] += i
        Thread.main[:i] += i
      end
    end

    Ramaze::Global[:i].should == Thread.main[:i]
    Ramaze::Global[:i].should == 55
  end
end