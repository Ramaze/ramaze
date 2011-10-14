Ramaze.setup(:verbose => false) do
  gem 'redis'
end

module Ramaze
  class Cache
    ##
    # The Redis cache is a cache driver for Redis (http://redis.io/). Redis is a
    # key/value store similar to Memcached but with the ability to flush data to
    # a file among various other features.
    #
    # The usage of this cache is very similar to the Memcache driver. You load
    # it by simply specifying the class:
    #
    #     Ramaze::Cache.options.session = Ramaze::Cache::Redis
    #
    # If you want to specify custom options you can do so by calling {.using} on
    # the class:
    #
    #     Ramaze::Cache.options.session = Ramaze::Cache::Redis.using(...)
    #
    # @example Using a custom Redis host
    #  Ramaze::Cache.options.names.push(:redis)
    #  Ramaze::Cache.options.redis = Ramaze::Cache::Redis.using(
    #    :host => '123.124.125.126',
    #    :port => 6478
    #  )
    #
    # @author Michael Fellinger
    # @since  09-10-2011
    #
    class Redis
      include Cache::API
      include Innate::Traited

      # Hash containing all the default options to use when no custom ones are
      # specified in .using().
      trait :default => {
        :expires_in => 604800,
        :host       => 'localhost',
        :port       => 6379
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
        # For example, the Redis cache for your sessions could be located at
        # server #1 while a custom cache is located on server #2.
        #
        # @author Yorick Peterse
        # @since  09-10-2011
        # @param  [Hash] options A hash containing custom options.
        # @option options [Fixnum] :expires_in The default time after which a
        #  key should expire.
        # @option options [String] :host The hostname of the machine on which
        #  Redis is running.
        # @option options [Fixnum] :port The port number to connect to.
        #
        def using(options = {})
          merged = Ramaze::Cache::Redis.trait[:default].merge(options)
          Class.new(self) { @options = merged }
        end
      end # class << self

      ##
      # Creates a new instance of the cache and merges the options if they
      # haven't already been set.
      #
      # @author Michael Fellinger
      # @param  [Hash] options A hash with custom options. See
      #  Ramaze::Cache::Redis.using() and the trait :default for more
      #  information.
      #
      def initialize(options = {})
        self.class.options ||= Ramaze::Cache::Redis.trait[:default].merge(
          options
        )

        @options = options.merge(self.class.options)
      end

      ##
      # Prepares the cache by setting up the namespace and loading Redis.
      #
      # @author Michael Fellinger
      # @since  09-10-2011
      # @param  [String] hostname The host of the machine that's running the
      #  Ramaze application.
      # @param  [String] username The name of the user that's running the
      #  application.
      # @param  [String] appname The name of the application (:pristine by
      #  default).
      # @param  [String] cachename The namespace to use for this cache instance.
      #
      def cache_setup(hostname, username, appname, cachename)
        options[:namespace] = [
          hostname, username, appname, cachename
        ].compact.join('-')

        @client = ::Redis.new(options)
      end

      ##
      # Clears the entire cache.
      #
      # @author Michael Fellinger
      # @since  09-10-2011
      #
      def cache_clear
        @client.flushall
      end

      ##
      # Removes a number of keys from the cache.
      #
      # @author Michael Fellinger
      # @param  [Array] *keys An array of key names to remove.
      #
      def cache_delete(*keys)
        @client.del(*keys)
      end

      ##
      # Retrieves the value of the given key. If no value could be retrieved the
      # default value (set to nil by default) will be returned instead.
      #
      # @author Michael Fellinger
      # @param  [String] key The name of the key to retrieve.
      # @param  [Mixed] default The default value.
      # @return [Mixed]
      #
      def cache_fetch(key, default = nil)
        value = @client.get(key)
        value.nil? ? default : value
      end

      ##
      # Stores a new value under the given key.
      #
      # @author Michael Fellinger
      # @param  [String] key The name of the key to store.
      # @param  [Mixed] value The value of the key.
      # @param  [Fixnum] ttl The Time To Live of the key.
      # @param  [Hash] options A hash containing key specific options.
      # @option options :expires_in The time after which the key should expire.
      #
      def cache_store(key, value, ttl = nil, options = {})
        ttl = options[:ttl] || @options[:expires_in]
        @client.setex(key, ttl, value)

        return value
      end
    end # Redis
  end # Cache
end # Ramaze
