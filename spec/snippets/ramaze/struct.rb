#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe Ramaze::Struct do
  should 'provide #values_at' do
    Point = Ramaze::Struct.new(:x, :y)
    point = Point.new(15, 10)

    point.values_at(1, 0).should == [10, 15]
    point.values_at(0..1).should == [15, 10]
    point.values_at(:y, :x).should == [10, 15]
  end
end
