#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe Ramaze::Dictionary do
  Dictionary = Ramaze::Dictionary

  should 'create' do
    dict = Dictionary['z', 1, 'a', 2, 'c', 3]
    dict.keys.should == %w[z a c]
  end

  should 'store' do
    dict = Dictionary.new
    dict['z'] = 1
    dict['a'] = 2
    dict['c'] = 3
    dict.keys.should == %w[z a c]

    dict = Dictionary.new
    dict[:a] = 1
    dict[:c] = 3
    dict.values.should == [1, 3]
    dict.keys.should == [:a, :c]

    dict[:b, 1] = 2
    dict.values.should == [1, 2, 3]
    dict.keys.should == [:a, :b, :c]
  end

  should 'push' do
    dict = Dictionary.new
    dict.push('end', 15).should == true
    dict['end'].should == 15
    dict.push('end', 30).should == false
    dict['end'].should == 15
  end

  should 'unshift' do
    dict = Dictionary['a', 1, 'c', 2, 'z', 3]
    dict.push('end', 15).should == true
    dict.unshift('begin', 50).should == true
    dict['begin'].should == 50
    dict.keys.should == %w[begin a c z end]
  end

  should 'pop' do
    dict = Dictionary['a', 1, 'c', 2, 'z', 3]
    dict.pop.should == ['z', 3]
    dict.keys.should == %w[a c]
  end

  should 'shift' do
    dict = Dictionary['a', 1, 'c', 2, 'z', 3]
    dict.shift.should == ['a', 1]
    dict.keys.should == %w[c z]
  end

  should 'insert' do
    dict_a = Dictionary['a', 1, 'b', 2, 'c', 3]
    dict_b = Dictionary['d', 4, 'a', 1, 'b', 2, 'c', 3]

    dict_a.insert(0, 'd', 4).should == 4
    dict_a.should == dict_b

    dict_c = Dictionary['a', 1, 'b', 2, 'c', 3]
    dict_d = Dictionary['a', 1, 'b', 2, 'c', 3, 'd', 4]

    dict_c.insert(-1, 'd', 4)
    dict_c.should == dict_d
  end

  should 'update with Dictionary' do
    left = Dictionary['a', 1, 'b', 2, 'c', 3]
    right = Dictionary['d', 4]
    result = Dictionary['a', 1, 'b', 2, 'c', 3, 'd', 4]

    left.update(right).should == result
    left.should == result
  end

  should 'update with Hash' do
    left = Dictionary['a', 1, 'b', 2, 'c', 3]
    right = { 'd' => 4 }
    result = Dictionary['a', 1, 'b', 2, 'c', 3, 'd', 4]
    left.update(right).should == result
    left.should == result
  end

  should 'merge with Dictionary' do
    left = Dictionary['a', 1, 'b', 2, 'c', 3]
    right = Dictionary['d', 4]
    result = Dictionary['a', 1, 'b', 2, 'c', 3, 'd', 4]
    left.merge(right).should == result
    left.should.not == result
  end

  should 'merge with Hash' do
    left = Dictionary['a', 1, 'b', 2, 'c', 3]
    right = { 'd' => 4 }
    result = Dictionary['a', 1, 'b', 2, 'c', 3, 'd', 4]
    left.merge(right).should == result
    left.should.not == result
  end

  should 'order by set order_by' do
    dict = Dictionary['a', 3, 'b', 2, 'c', 1]
    dict.order_by{|k,v| v }
    dict.values.should == [1, 2, 3]
    dict.keys.should == %w[c b a]
  end
end
