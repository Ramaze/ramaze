module Ramaze
  # A Hash-alike LRU cache that provides fine-grained control over content
  # restrictions.
  #
  # It allows you to set:
  # * a maximum number of elements
  # * the maximum amount of memory used for all elements
  # * the allowed memory-size per element
  # * time to live
  #
  # Differences to the original implementation include:
  # * The Cache is now a Struct for speed
  # * Object memory size is obtained via Marshal::dump instead of #to_s
  #
  # Note that due to calculating object size with Marshal, you might have to do
  # some evaluation as to how large your values will be when marshaled, for
  # example a String will have String#size + 10. This differs from object to
  # object and between versions of Marshal, so be generous.
  #
  # Copyright (C) 2002  Yoshinori K. Okuji <okuji@enbug.org>
  # Copyright (c) 2009  Michael Fellinger  <manveru@rubyists.com>
  #
  # You may redistribute it and/or modify it under the same terms as Ruby.
  class LRUHash < Struct.new(:max_total, :max_value, :max_count, :expiration,
                              :hook, :objs, :total_size, :list, :hits, :misses)
    CacheObject = Struct.new(:content, :size, :atime)
    VERSION = '0.3'

    # On 1.8 we raise IndexError, on 1.9 we raise KeyError
    KeyError = Module.const_defined?(:KeyError) ? KeyError : IndexError

    include Enumerable

    def initialize(options = {}, &hook)
      self.max_value  = options[:max_value]
      self.max_total  = options[:max_total]
      self.max_count  = options[:max_count]
      self.expiration = options[:expiration]

      avoid_insane_options

      self.hook = hook

      self.objs = {}
      self.list = []

      self.total_size = 0
      self.hits = self.misses = 0
    end

    def key?(key)
      objs.key?(key)
    end

    def value?(given_value)
      objs.each do |key, obj|
        return true if given_value == obj.content
      end

      false
    end

    def index(given_value)
      objs.each do |key, obj|
        return key if given_value == obj.content
      end

      nil
    end

    def keys
      objs.keys
    end

    def size
      objs.size
    end
    alias length size

    def to_hash
      objs.dup
    end

    def values
      objs.map{|key, obj| obj.content }
    end

    def delete(key)
      return unless objs.key?(key)
      obj = objs[key]

      hook.call(key, obj.content) if hook
      self.total_size -= obj.size
      objs.delete key

      list.delete_if{|list_key| key == list_key }

      obj.content
    end
    alias invalidate delete

    def clear
      objs.each{|key, obj| hook.call(key, obj) } if hook
      objs.clear
      list.clear
      self.total_size = 0
    end
    alias invalidate_all clear

    def expire
      return unless expiration
      now = Time.now.to_i

      list.each_with_index do |key, index|
        break unless (objs[key].atime + expiration) <= now
        invalidate key
      end
    end

    def [](key)
      expire

      unless objs.key?(key)
        self.misses += 1
        return
      end

      obj = objs[key]
      obj.atime = Time.now.to_i

      list.delete_if{|list_key| key == list_key }
      list << key

      self.hits += 1
      obj.content
    end

    def []=(key, obj)
      expire

      invalidate key if key?(key)

      size = Marshal.dump(obj).size

      if max_value && max_value < max_total
        warn "%p isn't cached because it exceeds max_value %p" % [obj, max_value]
        return obj
      end

      if max_value.nil? && max_total && max_total < size
        warn "%p isn't cached because it exceeds max_total: %p" % [obj, max_total]
        return obj
      end

      invalidate list.first if max_count && max_count == list.size

      self.total_size += size

      if max_total
        invalidate list.first until total_size < max_total
      end

      objs[key] = CacheObject.new(obj, size, Time.now.to_i)
      list << key

      obj
    end

    def store(key, value)
      self[key] = value
    end

    def each_pair
      return enum_for(:each_pair) unless block_given?
      objs.each{|key, obj| yield key, obj.content }
      self
    end

    def each_key(&block)
      return enum_for(:each_key) unless block_given?
      objs.each_key{|key| yield key }
      self
    end

    def each_value
      return enum_for(:each_value) unless block_given?
      objs.each_value{|obj| yield obj.content }
      self
    end

    def empty?
      objs.empty?
    end

    # Note that this method diverges from the default behaviour of the Ruby Hash.
    # If the cache doesn't find content for the given key, it will store the
    # given default instead. Optionally it also takes a block, the return value
    # of the block is then stored and returned.
    #
    # @example
    #
    #   lru = LRUHash.new
    #   lru.fetch(:a) # => KeyError: key not found: :a
    #   lru.fetch(:a, :b) # => :b
    #   lru.fetch(:a) # => :b
    #   lru.fetch(:c){|key| key.to_s } # => 'c'
    #   lru.fetch(:c) # => 'c'
    def fetch(key, default = (p_default = true; nil))
      if key?(key)
        value = self[key]
      elsif p_default.nil?
        value = self[key] = default
      elsif block_given?
        value = self[key] = yield(key)
      else
        raise KeyError, "key not found: %p" % [key]
      end

      value
    end

    def statistics
      {:size => total_size, :count => list.size, :hits => hits, :misses => misses}
    end

    private

    # Sanity checks.
    def avoid_insane_options
      if (max_value && max_total) && max_value > max_total
        raise ArgumentError, "max_value exceeds max_total (#{max_value} > #{max_total})"
      end
      if max_value && max_value <= 0
        raise ArgumentError, "invalid max_value `#{max_value}'"
      end
      if max_total && max_total <= 0
        raise ArgumentError, "invalid max_total `#{max_total}'"
      end
      if max_count && max_count <= 0
        raise ArgumentError, "invalid max_count `#{max_count}'"
      end
      if expiration && expiration <= 0
        raise ArgumentError, "invalid expiration `#{expiration}'"
      end
    end
  end # LRUHash
end # Ramaze
