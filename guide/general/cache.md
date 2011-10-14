# Caching Data

Caching data such as API responses, compiled templates or database results can
give your application a big performance boost. Ramaze tries to make this as easy
as possible by providing an API that allows you to use different cache
mechanisms such as Memcache or Sequel using the same syntax.

## Available Drivers

* {Ramaze::Cache::Sequel}
* {Ramaze::Cache::LRU}
* {Ramaze::Cache::MemCache}
* {Ramaze::Cache::Redis}
* {Ramaze::Cache::LocalMemCache}
* {Innate::Cache::FileBased}
* {Innate::Cache::DRb}
* {Innate::Cache::Marshal}
* {Innate::Cache::Memory}
* {Innate::Cache::YAML}

## Manually Caching Data

Besides making it easy to automatically cache various forms of data Ramaze also
allows you to manually cache something using your favorite storage engine. In
order to do this you'll first have to configure Ramaze so that it knows that you
want to cache something, this can be done as following:

    Ramaze::Cache.options.names.push(:custom)
    Ramaze::Cache.options.custom = Ramaze::Cache::MemCache

    # Now we can cache the data
    Ramaze::Cache.custom.store('usernames', ['Pistos', 'Michael Fellinger'])

From this point on you can cache your data by calling methods on
``Ramaze::Cache.custom``.

## Creating Drivers

Odds are there's a cache driver out there that's not supported out of the box.
Don't worry, adding your own cache driver is pretty easy and I'll try to explain
it as best as I can.

The first step is creating a basic skeleton for our cache class. In it's most
basic form it looks like the following:

    # It's not required to declare the cache under the Ramaze namespace, feel free
    # to use a different name.
    module Ramaze
      # Note that Ramaze::Cache is a class, not a module.
      class Cache
        # This is our own custom cache class
        class CustomCache
          # Pre defines the required methods. This ensures all cache drivers can
          # be used in the same way
          include Cache::API

        end
      end
    end

The next step is to override the methods that were created by including
Ramaze::Cache::API. The first step is adding the method that prepares the cache
by loading the driver provided by an external Rubygem (e.g. Dalli::Client for
the Memcache driver) and creating the namespace for the cache. Assuming our gem
is called "custom-cache" and the class it provides CustomCacheGem our
cache_setup (that's the name of the setup method) method would look like the
following:

    def cache_setup(hostname, username, appname, cachename)
      @namespace = [hostname, username, appname, cachename].compact.join('-')
      @client    = CustomCacheGem.new(:namespace => @namespace)
    end

The next step is to add the remaining methods so that we can actually use the
cache.

    # Removes *all* keys from the cache
    def cache_clear
      @client.delete_all
    end

    # Removes the specified keys from the cache
    def cache_delete(*keys)
      keys.each do |k|
        @client.delete(k)
      end
    end

    # Retrieves the specified key or returns the default value
    def cache_fetch(key, default = nil)
      value = @client.get(key)

      if !value.nil?
        return value
      else
        return default
      end
    end

    # Stores the data in the cache and return the value
    def cache_store(key, value)
      @client.set(key, value)
      return value
    end

Depending on the API of your cache mechanism the method names and the way
they're used may vary.

The entire cache class now looks like the following:

    # It's not required to declare the cache under the Ramaze namespace, feel free
    # to use a different name.
    module Ramaze
      # Note that Ramaze::Cache is a class, not a module.
      class Cache
        # This is our own custom cache class
        class CustomCache
          # Pre defines the required methods. This ensures all cache drivers can
          # be used in the same way
          include Cache::API

          # Prepares the cache
          def cache_setup(hostname, username, appname, cachename)
            @namespace = [hostname, username, appname, cachename].compact.join('-')
            @client    = CustomCacheGem.new(:namespace => @namespace)
          end

          # Removes *all* keys from the cache
          def cache_clear
            @client.delete_all
          end

          # Removes the specified keys from the cache
          def cache_delete(*keys)
            keys.each do |k|
              @client.delete(k)
            end
          end

          # Retrieves the specified key or returns the default value
          def cache_fetch(key, default = nil)
            value = @client.get(key)

            if !value.nil?
              return value
            else
              return default
            end
          end

          # Stores the data in the cache and return the value
          def cache_store(key, value)
            @client.set(key, value)
            return value
          end
        end # CustomCache
      end # Cache
    end # Ramaze

There really isn't that much to it when it comes to creating a cache driver. The
important thing to remember is that the following methods are always required:

* cache_setup
* cache_clear
* cache_delete
* cache_fetch
* cache_store
