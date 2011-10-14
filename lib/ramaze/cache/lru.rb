#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Cache
    ##
    # Cache class that uses {Ramaze::LRUHash} as a storage engine. This cache
    # has the advantage that unlike Innate::Cache::Memory it does not leak
    # memory over time when using the cache for sessions.
    #
    # @example
    #  Ramaze::Cache.options.session = Ramaze::Cache::LRU
    #  Ramaze.setup_dependencies
    #
    # @author Michael Fellinger
    # @since  17-07-2009
    #
    class LRU
      include Cache::API

      # Hash containing all the options for the cache.
      OPTIONS = {
        # expiration in seconds
        :expiration => nil,
        # maximum elements in the cache
        :max_count => 10000,
        # maximum total memory usage of the cache
        :max_total => nil,
        # maximum memory usage of an element of the cache
        :max_value => nil,
      }

      ##
      # Prepares the cache by creating a new instance of Ramaze::LRUHash using
      # the options set in {Ramaze::Cache::LRU::OPTIONS}.
      #
      # @author Michael Fellinger
      # @since  17-07-2009
      #
      def cache_setup(host, user, app, name)
        @store = Ramaze::LRUHash.new(OPTIONS)
      end

      ##
      # Clears the entire cache.
      #
      # @author Michael Fellinger
      # @since  17-07-2009
      #
      def cache_clear
        @store.clear
      end

      ##
      # Stores a set of data in the cache.
      #
      # @author Michael Fellinger
      # @since  17-07-2009
      # @see    Innate::Cache::API#cache_store
      #
      def cache_store(*args)
        super { |key, value| @store[key] = value }
      end

      ##
      # Retrieves a set of data from the cache.
      #
      # @author Michael Fellinger
      # @since  17-07-2009
      # @see    Innate::Cache::API#cache_fetch
      #
      def cache_fetch(*args)
        super { |key| @store[key] }
      end

      ##
      # Deletes a set of data from the cache
      #
      # @author Michael Fellinger
      # @since  17-07-2009
      # @see    Innate::Cache::API#cache_delete
      #
      def cache_delete(*args)
        super { |key| @store.delete(key) }
      end
    end # LRU
  end # Cache
end # Ramaze
