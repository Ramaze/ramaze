#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.
require 'innate/cache'

module Ramaze
  Cache = Innate::Cache

  #:nodoc:
  class Cache
    autoload :LRU,           'ramaze/cache/lru'
    autoload :LocalMemCache, 'ramaze/cache/localmemcache'
    autoload :MemCache,      'ramaze/cache/memcache'
    autoload :Sequel,        'ramaze/cache/sequel'
    autoload :Redis,         'ramaze/cache/redis'
    autoload :Moneta,        'ramaze/cache/moneta'

    ##
    # Overwrites {Innate::Cache#initialize} to make cache classes application
    # aware. This prevents different applications running on the same host and
    # user from overwriting eachothers data.
    #
    # @since 14-05-2012
    # @see   Innate::Cache#initialize
    #
    def initialize(name, klass = nil)
      @name      = name.to_s.dup.freeze
      klass    ||= options[@name.to_sym]
      @instance  = klass.new

      @instance.cache_setup(
        ENV['HOSTNAME'],
        ENV['USER'],
        Ramaze.options.app.name.to_s,
        @name
      )
    end

    ##
    # Clears the cache after a file has been reloaded.
    #
    # @author Michael Fellinger
    # @since  17-07-2009
    #
    def self.clear_after_reload
      action.clear if respond_to?(:action)
      action_value.clear if respond_to?(:action_value)
    end
  end # Cache
end # Ramaze
