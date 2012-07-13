#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe LRU = Ramaze::LRUHash do
  describe 'without restrictions' do
    it 'fetches via #fetch' do
      lru = LRU.new

      lambda{ lru.fetch(:a) }.should.raise(LRU::KeyError).message ==  "key not found: :a"
      lru.fetch(:a, :b).should == :b
      lru.fetch(:a).should == :b
      lru.fetch(:c){|key| key.to_s }.should == 'c'
      lru.fetch(:c).should == 'c'
    end

    it 'stores and retrieves values via #[]= and #[]' do
      lru = LRU.new

      lru[:a].should == nil
      lru[:a] = :b
      lru[:a].should == :b
    end
  end

  describe 'with max_count restriction' do
    it 'stores and retrieves values via #[]= and #[]' do
      lru = LRU.new(:max_count => 2)

      # store the allowed two
      lru[:a] = :b
      lru[:c] = :d

      # overflow by one
      lru[:e] = :f

      # first content must be gone
      lru.key?(:a).should == false

      # access :c to keep it around
      lru[:c]
      lru[:g] = :h

      lru.key?(:c).should == true
      lru.key?(:e).should == false
    end

    it 'should keep some statistics' do
      lru = LRU.new(:max_count => 2)
      lru.statistics.should == {:size => 0, :count => 0, :hits => 0, :misses => 0}

      lru[:a] = :b
      lru.statistics.should == {:size => 5, :count => 1, :hits => 0, :misses => 0}

      lru[:a] = :b
      lru.statistics.should == {:size => 5, :count => 1, :hits => 0, :misses => 0}

      lru[:c] = :d
      lru.statistics.should == {:size => 10, :count => 2, :hits => 0, :misses => 0}

      lru[:c]
      lru.statistics.should == {:size => 10, :count => 2, :hits => 1, :misses => 0}

      lru[:d]
      lru.statistics.should == {:size => 10, :count => 2, :hits => 1, :misses => 1}

      lru[:e] = :f
      lru.statistics.should == {:size => 10, :count => 2, :hits => 1, :misses => 1}

      lru[:a]
      lru.statistics.should == {:size => 10, :count => 2, :hits => 1, :misses => 2}

      lru.delete :e
      lru.statistics.should == {:size => 5, :count => 1, :hits => 1, :misses => 2}

      lru[:a] = 'foobar'
      s = lru.statistics
      s.delete(:size) # Differs on 1.8/1.9
      s.should == {:count => 2, :hits => 1, :misses => 2}
    end
  end

  # TODO: Still missing
  # :[], :[]=, :clear, :delete, :each_key, :each_pair, :each_value, :empty?,
  # :expire, :fetch, :index, :key?, :keys, :length, :size, :statistics, :store,
  # :to_hash, :value?, :values
end
