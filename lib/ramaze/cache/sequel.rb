Ramaze.setup(:verbose => false) do
  gem 'sequel'
end

module Ramaze
  class Cache
    ##
    # The Sequel cache is a cache system that uses the Sequel database toolkit
    # to store the data in a DBMS supported by Sequel. Examples of these
    # databases are MySQL, SQLite3 and so on. In order to use this cache you'd
    # have to do the following:
    #
    #     Ramaze::Cache.options.view = Ramaze::Cache::Sequel.using(
    #       :connection => Sequel.mysql(
    #         :host     => 'localhost',
    #         :user     => 'user',
    #         :password => 'password',
    #         :database => 'blog'
    #       ),
    #       :table => :blog_sessions
    #     )
    #
    # If you already have an existing connection you can just pass the object to
    # the :connection option instead of creating a new connection manually.
    #
    # Massive thanks to Lars Olsson for patching the original Sequel cache so
    # that it supports multiple connections and other useful features.
    #
    # @example Setting a custom database connection
    #  Ramaze::Cache.options.names.push(:sequel)
    #  Ramaze::Cache.options.sequel = Ramaze::Cache::Sequel.using(
    #    :connection => Sequel.connect(
    #      :adapter  => 'mysql2',
    #      :host     => 'localhost',
    #      :username => 'cache',
    #      :password => 'cache123',
    #      :database => 'ramaze_cache'
    #    )
    #  )
    #
    # @author Lars Olsson
    # @since  18-04-2011
    #
    class Sequel
      include Cache::API
      include Innate::Traited

      # Hash containing the default options
      trait :default => {
        # The default Sequel connection to use
        :connection => nil,

        # Whether or not warnings should be displayed
        :display_warnings => false,

        # The name of the default database table to use
        :table => 'ramaze_cache',

        # The default TTL to use
        :ttl => nil
      }

      # Hash containing all the default options merged with the user specified
      # ones
      attr_accessor :options

      class << self
        attr_accessor :options

        ##
        # This method returns a subclass of Ramaze::Cache::Sequel with the
        # provided options set. This is necessary because Ramaze expects a class
        # and not an instance of a class for its cache option.
        #
        # You can provide any parameters you want, but those not used by the
        # cache will not get stored. No parameters are mandatory. Any missing
        # parameters will be replaced by default values.
        #
        # @example
        #  ##
        #  # This will create a mysql session cache in the blog
        #  # database in the table blog_sessions
        #  # Please note that the permissions on the database must
        #  # be set up correctly before you can just create a new table
        #  #
        #  Ramaze.options.cache.session = Ramaze::Cache::Sequel.using(
        #    :connection => Sequel.mysql(
        #      :host     =>'localhost',
        #      :user     =>'user',
        #      :password =>'password',
        #      :database =>'blog'
        #    ),
        #    :table => :blog_sessions
        #  )
        #
        # @author Lars Olsson
        # @since  18-04-2011
        # @param  [Object] options A hash containing the options to use
        # @option options [Object] :connection a Sequel database object
        #  (Sequel::Database) You can use any parameters that Sequel supports for
        #  this object. If this option is left unset, a Sqlite memory database
        #  will be used.
        # @option options [String] :table The table name you want to use for the
        #  cache. Can be either a String or a Symbol. If this option is left
        #  unset, a table called ramaze_cache will be used.
        # @option options [Fixnum] :ttl Setting this value will override
        #  Ramaze's default setting for when a particular cache item will be
        #  invalidated. By default this setting is not used and the cache uses
        #  the values provided by Ramaze, but if you want to use this setting it
        #  should be set to an integer representing the number of seconds before
        #  a cache item becomes invalidated.
        # @option options [TrueClass] :display_warnings When this option is set
        #  to true, failure to serialiaze or deserialize cache items will produce
        #  a warning in the Ramaze log. This option is set to false by default.
        #  Please note that certain objects (for instance Procs) cannot be
        #  serialized by ruby and therefore cannot be cached by this cache class.
        #  Setting this option to true is a good way to find out if the stuff you
        #  are trying to cache is affected by this. Failure to
        #  serialize/deserialize a cache item will never raise an exception, the
        #  item will just remain uncached.
        # @return [Object]
        #
        def using(options = {})
          merged = Ramaze::Cache::Sequel.trait[:default].merge(options)
          Class.new(self) { @options = merged }
        end
      end

      ##
      # Creates a new instance of the cache class.
      #
      # @author Michael Fellinger
      # @since  04-05-2011
      # @param  [Hash] options A hash with custom options, see
      #  Ramaze::Cache::Sequel.using for all available options.
      #
      def initialize(options = {})
        self.class.options ||= Ramaze::Cache::Sequel.trait[:default].merge(
          options
        )

        @options = options.merge(self.class.options)
      end

      ##
      # Executed after #initialize and before any other method.
      #
      # Some parameters identifying the current process will be passed so caches
      # that act in one global name-space can use them as a prefix.
      #
      # @author Lars Olsson
      # @since  18-04-2011
      # @param  [String] hostname  the hostname of the machine
      # @param  [String] username  user executing the process
      # @param  [String] appname   identifier for the application
      # @param  [String] cachename namespace, like 'session' or 'action'
      #
      def cache_setup(hostname, username, appname, cachename)
        @namespace = [hostname, username, appname, cachename].compact.join(':')

        # Create the table if it's not there yet
        if !options[:connection].table_exists?(options[:table])
          options[:connection].create_table(
            options[:table]) do
            primary_key :id
            String :key  , :null => false, :unique => true
            String :value, :text => true
            Time :expires
          end
        end

        @dataset = options[:connection][options[:table].to_sym]
      end

      ##
      # Remove all key/value pairs from the cache. Should behave as if #delete
      # had been called with all +keys+ as argument.
      #
      # @author Lars Olsson
      # @since  18-04-2011
      #
      def cache_clear
        @dataset.delete
      end

      ##
      # Remove the corresponding key/value pair for each key passed. If removing
      # is not an option it should set the corresponding value to nil.
      #
      # If only one key was deleted, answer with the corresponding value. If
      # multiple keys were deleted, answer with an Array containing the values.
      #
      # @author Lars Olsson
      # @since  18-04-2011
      # @param  [Object] key The key for the value to delete
      # @param  [Object] keys Any other keys to delete as well
      # @return [Object/Array/nil]
      #
      def cache_delete(key, *keys)
        # Remove a single key
        if keys.empty?
          nkey   = namespaced(key)
          result = @dataset.select(:value).filter(:key => nkey).limit(1)

          # Ramaze expects nil values
          if result.empty?
            result = nil
          else
            result = deserialize(result.first[:value])
          end

          @dataset.filter(:key => nkey).delete
        # Remove multiple keys
        else
          nkeys  = [key, keys].flatten.map! { |nkey| namespaced(nkey) }
          result = dataset.select(:value).filter(:key => nkeys)

          result.map! do |row|
            deserialize(row[:value])
          end

          @dataset.filter(:key => nkeys).delete
        end

        return result
      end

      ##
      # Answer with the value associated with the +key+, +nil+ if not found or
      # expired.
      #
      # @author Lars Olsson
      # @since  18-04-2011
      # @param  [Object] key The key for which to fetch the value
      # @param  [Object] default Will return this if no value was found
      # @return [Object]
      #
      def cache_fetch(key, default = nil)
        nkey = namespaced(key)

        # Delete expired rows
        @dataset.select.filter(:key => nkey) do
          expires < Time.now
        end.delete

        # Get remaining row (if any)
        result = @dataset.select(:value).filter(:key => nkey).limit(1)

        if result.empty?
          return default
        else
          return deserialize(result.first[:value])
        end
      end

      ##
      # Sets the given key to the given value.
      #
      # @example
      #  Cache.value.store(:num, 3, :ttl => 20)
      #  Cache.value.fetch(:num)
      #
      # @author Lars Olsson
      # @since  18-04-2011
      # @param  [Object] key The value is stored with this key
      # @param  [Object] value The key points to this value
      # @param  [Hash] options for now, only :ttl => Fixnum is used.
      # @option options [Fixnum] :ttl The time in seconds after which the cache
      #  item should be expired.
      #
      def cache_store(key, value, options = {})
        nkey = namespaced(key)

        # Get the time after which the cache should be expired
        if options[:ttl]
          ttl = options[:ttl]
        else
          ttl = Ramaze::Cache::Sequel.options[:ttl]
        end

        expires = Time.now + ttl if ttl

        # The row already exists, update it.
        if @dataset.filter(:key => nkey).count == 1
          serialized_value = serialize(value)

          if serialized_value
            @dataset.update(:value => serialize(value), :expires => expires)
          end
        # The row doesn't exist yet.
        else
          serialized_value = serialize(value)

          if serialized_value
            @dataset.insert(
              :key => nkey, :value => serialize(value), :expires => expires
            )
          end
        end

        # Try to deserialize the value. If this fails we'll return a different
        # value
        deserialized = deserialize(@dataset.select(:value).filter(:key => nkey)
          .limit(1).first[:value])

        if deserialized
          return deserialized
        else
          return value
        end
      end

      ##
      # Prefixes the given key with current namespace.
      #
      # @author Lars Olsson
      # @since  18-04-2011
      # @param  [Object] key Key without namespace.
      # @return [Object]
      #
      def namespaced(key)
        return [@namespace, key].join(':')
      end

      ##
      # Deserialize method, adapted from Sequels serialize plugin
      # This method will try to deserialize a value using Marshal.load
      #
      # @author Lars Olsson
      # @since  18-04-2011
      # @param  [Object] value Value to be deserialized
      # @return [Object nil]
      #
      def deserialize(value)
        begin
          ::Marshal.load(value.unpack('m')[0])
        rescue
          begin
            ::Marshal.load(value)
          rescue
            # Log the error?
            if options[:display_warnings] === true
              Ramaze::Log::warn("Failed to deserialize #{value.inspect}")
            end

            return nil
          end
        end
      end

      ##
      # Serialize method, adapted from Sequels serialize plugin
      # This method will try to serialize a value using Marshal.dump
      #
      # @author Lars Olsson
      # @since  18-04-2011
      # @param  [Object] value Value to be serialized.
      # @return [Object nil]
      #
      def serialize(value)
        begin
          [::Marshal.dump(value)].pack('m')
        rescue
          if options[:display_warnings] === true
            Ramaze::Log::warn("Failed to serialize #{value.inspect}")
          end

          return nil
        end
      end
    end # Sequel
  end # Cache
end # Ramaze
