require 'moneta'

module Ramaze
  class Cache
    ##
    # The Moneta cache is a cache driver for Moneta (http://github.com/minad/moneta). Moneta is a
    # unified interface to key/value stores.
    #
    # The usage of this cache is very similar to the Memcache driver. You load
    # it by simply specifying the class:
    #
    #     Ramaze::Cache.options.session = Ramaze::Cache::Moneta
    #
    # If you want to specify custom options you can do so by calling {.using} on
    # the class:
    #
    #     Ramaze::Cache.options.session = Ramaze::Cache::Moneta.using(...)
    #
    # @example Configuring the Moneta backend
    #  Ramaze::Cache.options.names.push(:moneta)
    #  Ramaze::Cache.options.moneta = Ramaze::Cache::Moneta.using(
    #    :adapter => :File,
    #    :dir => './ramaze-cache'
    #  )
    #
    # @author Daniel Mendler
    #
    class Moneta
      include Cache::API
      include Innate::Traited

      # Hash containing all the default options to use when no custom ones are
      # specified in .using().
      trait :default => {
        :expires_in => 604800,
        :adapter => :Memory,
      }

      # Hash containing all the default options merged with the user specified
      # ones.
      attr_accessor :options

      class << self
        attr_accessor :options

        ##
        # Creates a new instance of the cache class and merges the default
        # options with the custom ones.
        #
        # Using this method you can specify custom options for various caches.
        # For example, the Moneta cache for your sessions could be located at
        # server #1 while a custom cache is located on server #2.
        #
        # @author Daniel Mendler
        # @param  [Hash] options A hash containing custom options.
        # @option options [Fixnum] :expires_in The default time after which a
        #  key should expire.
        # @option options [Symbol] :adapter Moneta adapter
        #
        def using(options = {})
          merged = Ramaze::Cache::Moneta.trait[:default].merge(options)
          Class.new(self) { @options = merged }
        end
      end # class << self

      ##
      # Creates a new instance of the cache and merges the options if they
      # haven't already been set.
      #
      # @author Daniel Mendler
      # @param  [Hash] options A hash with custom options. See
      #  Ramaze::Cache::Moneta.using() and the trait :default for more
      #  information.
      #
      def initialize(options = {})
        self.class.options ||=
          Ramaze::Cache::Moneta.trait[:default].merge(options)

        @options = options.merge(self.class.options)
      end

      ##
      # Prepares the cache by setting up the prefix and loading Moneta.
      #
      # @author Daniel Mendler
      #
      def cache_setup(*args)
        opts = options.dup
        opts[:prefix] = ['ramaze', *args].compact.join(':')
        opts[:expires] = opts.delete(:expires_in)
        adapter = opts.delete(:adapter)
        @moneta = ::Moneta.new(adapter, options)
      end

      ##
      # Clears the entire cache.
      #
      # @author Daniel Mendler
      #
      def cache_clear
        @moneta.clear
      end

      ##
      # Removes a number of keys from the cache.
      #
      # @author Daniel Mendler
      # @param  [Array] keys An array of key names to remove.
      #
      def cache_delete(*keys)
        keys.each {|key| @moneta.delete(key) }
      end

      ##
      # Retrieves the value of the given key. If no value could be retrieved the
      # default value (set to nil by default) will be returned instead.
      #
      # @author Daniel Mendler
      # @param  [String] key The name of the key to retrieve.
      # @param  [Mixed] default The default value.
      # @return [Mixed]
      #
      def cache_fetch(key, default = nil)
        @moneta.fetch(key, default)
      end

      ##
      # Stores a new value under the given key.
      #
      # @author Daniel Mendler
      # @param  [String] key The name of the key to store.
      # @param  [Mixed] value The value of the key.
      # @param  [Fixnum] ttl The Time To Live of the key.
      # @param  [Hash] options A hash containing key specific options.
      # @option options :expires_in The time after which the key should expire.
      #
      def cache_store(key, value, ttl = nil, options = {})
        options[:expires] = options.delete(:ttl) || @options[:expires_in]
        @moneta.store(key, value, options)
      end
    end # Moneta
  end # Cache
end # Ramaze
