require 'dalli'

# Kgio gives a nice performance boost but it isn't required
begin; require 'kgio'; rescue LoadError => e; end

#:nodoc:
module Ramaze
  #:nodoc:
  class Cache
    ##
    # Cache driver for the Memcache storage engine. Memcache is a key/value
    # store that's extremely useful for caching data such as views or API
    # responses. More information about Memcache can be found on it's website:
    # <http://memcached.org/>.
    #
    # Note that this cache driver requires the Dalli gem rather than Memcache
    # Client. The reason for this is that the Memcache client hasn't been
    # updated in over a year and Memcache has changed quite a bit. Dalli is also
    # supposed to be faster and better coded. This cache driver will also try to
    # load the kgio Gem if it's installed, if it's not it will just continue to
    # operate but you won't get the nice speed boost.
    #
    # This driver works similar to Ramaze::Cache::Sequel in that it allows you
    # to specify instance specific options using the using() method:
    #
    #     Ramaze::Cache.options.session = Ramaze::Cache::MemCache.using(
    #       :compression => false
    #     )
    #
    # All options sent to the using() method will be sent to Dalli.
    #
    # @example Using the default options
    #  Ramaze::Cache.options.view = Ramaze::Cache::MemCache
    #  Ramaze.setup_dependencies
    #
    #  Ramaze::Cache.view.store(:my_view, 'Hello Ramaze')
    #
    # @example Using custom options
    #  Ramaze::Cache.options.view = Ramaze::Cache::MemCache.using(
    #    :compression => false,
    #    :servers     => ['localhost:11211', 'localhost:112112']
    #  )
    #
    #  Ramaze.setup_dependencies
    #  Ramaze::Cache.view.store(:my_view, 'Hello Ramaze')
    #
    # @author Yorick Peterse
    # @since  04-05-2011
    #
    class MemCache
      include Cache::API
      include Innate::Traited

      # The maximum Time To Live that can be used in Memcache
      MAX_TTL = 2592000

      # Hash containing the default configuration options to use for Dalli
      trait :default => {
        # The default TTL for each item
        :expires_in => 604800,

        # Compresses everything with Gzip if it's over 1K
        :compress => true,

        # Array containing all default Memcache servers
        :servers => ['localhost:11211']
      }

      # Hash containing all the default options merged with the user specified
      # ones
      attr_accessor :options

      class << self
        attr_accessor :options

        ##
        # This method will create a subclass of Ramaze::Cache::MemCache with all
        # the custom options set. All options set in this method will be sent to
        # Dalli as well.
        #
        # Using this method allows you to use different memcache settings for
        # various parts of Ramaze. For example, you might want to use servers A
        # and B for storing the sessions but server C for only views. Most of
        # the way this method works was inspired by Ramaze::Cache::Sequel which
        # was contributed by Lars Olsson.
        #
        # @example
        #  Ramaze::Cache.options.session = Ramaze::Cache::MemCache.using(
        #    :compression => false,
        #    :username    => 'ramaze',
        #    :password    => 'ramaze123',
        #    :servers     => ['othermachine.com:12345']
        #  )
        #
        # @author Yorick Peterse
        # @since  04-05-2011
        # @param  [Hash] options A hash containing all configuration options to
        #  use for Dalli. For more information on all the available options you
        #  can read the README in their repository. This repository can be found
        #  here: https://github.com/mperham/dalli
        #
        def using(options = {})
          merged = Ramaze::Cache::MemCache.trait[:default].merge(options)
          Class.new(self) { @options = merged }
        end
      end # class << self

      ##
      # Creates a new instance of the cache class.
      #
      # @author Michael Fellinger
      # @since  04-05-2011
      # @param  [Hash] options A hash with custom options, see
      #  Ramaze::Cache::MemCache.using for all available options.
      #
      def initialize(options = {})
        self.class.options ||= Ramaze::Cache::MemCache.trait[:default].merge(
          options
        )

        @options = options.merge(self.class.options)
      end

      ##
      # Prepares the cache by creating the namespace and an instance of a Dalli
      # client.
      #
      # @author Yorick Peterse
      # @since  04-05-2011
      # @param  [String] hostname  The hostname of the machine running the
      #  application.
      # @param  [String] username  The name of the user executing the process
      # @param  [String] appname   Unique identifier for the application.
      # @param  [String] cachename The namespace to use for this cache instance.
      #
      def cache_setup(hostname, username, appname, cachename)
        # Validate the maximum TTL
        if options[:expires_in] > MAX_TTL
          raise(ArgumentError, "The maximum TTL of Memcache is 30 days")
        end

        options[:namespace] = [
          hostname, username, appname, cachename
        ].compact.join('-')

        @client = ::Dalli::Client.new(options[:servers], options)
      end

      ##
      # Removes all items from the cache.
      #
      # @author Yorick Peterse
      # @since  04-05-2011
      #
      def cache_clear
        @client.flush
      end

      ##
      # Removes the specified keys from the cache.
      #
      # @author Yorick Peterse
      # @since  04-05-2011
      # @param  [Array] keys The keys to remove from the cache.
      #
      def cache_delete(*keys)
        keys.each do |key|
          @client.delete(key)
        end
      end

      ##
      # Fetches the specified key from the cache. It the value was nil the
      # default value will be returned instead.
      #
      # @author Yorick Peterse
      # @since  04-05-2011
      # @param  [String] key The name of the key to retrieve.
      # @param  [Mixed] default The default value.
      # @return [Mixed]
      #
      def cache_fetch(key, default = nil)
        value = @client.get(key)

        if value.nil?
          return default
        else
          return value
        end
      end

      ##
      # Sets the given key to the specified value. Optionally you can specify a
      # hash with options specific to the key. Once a key has been stored it's
      # value will be returned.
      #
      # @author Yorick Peterse
      # @since  04-05-2011
      # @param  [String] key The name of the key to store.
      # @param  [Mixed] value The value to store in Memcache.
      # @param  [Fixnum] ttl The Time To Live to use for the current key.
      # @param  [Hash] options A hash containing options specific for the
      #  specified key.
      # @return [Mixed]
      #
      def cache_store(key, value, ttl = nil, options = {})
        ttl = options.delete(:ttl) || @options[:expires_in]

        if ttl > MAX_TTL
          raise(ArgumentError, "The maximum TTL of Memcache is 30 days")
        end

        @client.set(key, value, ttl, options)

        return value
      end
    end # MemCache
  end # Cache
end # Ramaze
