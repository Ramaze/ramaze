#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'localmemcache'

module Ramaze
  class Cache
    # Cache based on the localmemcache library which utilizes mmap to share
    # strings in memory between ruby instances.
    class LocalMemCache
      include Cache::API

      OPTIONS = {
        :size_mb    => 1024,
        :serialize  => true,
        :serializer => ::Marshal, # something that responds to ::load and ::dump
      }

      # Connect to localmemcache
      def cache_setup(host, user, app, name)
        @namespace  = [host, user, app, name].compact.join('-')
        options     = {:namespace => @namespace}.merge(OPTIONS)

        @serialize  = options.delete(:serialize)
        @serializer = options.delete(:serializer)
        @store      = ::LocalMemCache.new(options)
      end

      # Wipe out _all_ data in localmemcached, use with care.
      def cache_clear
        @store.clear
      end

      def cache_delete(*args)
        super { |key| @store.delete(key.to_s); nil }
      end

      # NOTE:
      #   * We have no way of knowing whether the value really is nil, we
      #     assume you wouldn't cache nil and return the default instead.
      def cache_fetch(*args)
        super { |key|
          value = @store[key.to_s]
          @serializer.load(value) if value
        }
      end

      def cache_store(*args)
        super { |key, value| @store[key.to_s] = @serializer.dump(value) }
      end
    end # LocalMemCache
  end # Cache
end # Ramaze
