#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper
    ##
    # Caching of simple objects and whole action responses.
    #
    module Cache
      # Setup needed traits, add the singleton methods and add the caches used
      # by this helper.
      #
      # @param [Class] into Class that this Module is included into
      # @author manveru
      #
      def self.included(into)
        into.extend(SingletonMethods)
        into.add_action_wrapper(6.0, :cache_wrap)
        into.trait[:cache_action] ||= Set.new
        Ramaze::Cache.add(:action, :cache_helper_value)
      end

      ##
      # @param [Action] action The currently wrapped action
      # @yield The next block in wrap_action_call
      # @return [String] the response body
      # @see Innate::Node#wrap_action_call
      # @author manveru
      #
      def cache_wrap(action)
        cache = Innate::Cache.action

        ancestral_trait[:cache_action].each do |cache_action|
          temp  = cache_action.dup
          block = temp.delete(:key)
          ttl   = temp.delete(:ttl)

          if temp.all?{|key, value| action[key] == value }
            cache_key = action.full_path
            cache_key << "_#{action.instance.instance_eval(&block).to_s}" if block

            if cached = cache[cache_key]
              action.options[:content_type] = cached[:type]
            else
              cached = {
                :body => catch(:respond) { yield },
                :type => response['Content-Type']
              }

              if ttl
                cache.store(cache_key, cached, :ttl => ttl)
              else
                cache.store(cache_key, cached)
              end
            end

            return cached[:body]
          end
        end

        yield
      end

      ##
      # This method is used to access Ramaze::Cache.cache_helper_value.
      # It provides an easy way to cache long-running computations, gathering
      # external resources like RSS feeds or DB queries that are the same for
      # every user of an application.
      # This method changes behaviour if a block is passed, which can be used
      # to do lazy computation of the cached value conveniently when using a
      # custom TTL or longer expressions that don't fit on one line with ||=.
      #
      # @example to get the cache object directly
      #
      #   count = cache_value[:count] ||= Article.count
      #
      # @example with block
      #
      #   count = cache_value(:count){ Article.count }
      #   count = cache_value(:count, :ttl => 60){ Article.count }
      #
      # @return [Object] The cache wrapper assigned for :cache_helper_value
      # @see Innate::Cache
      # @author manveru
      #
      def cache_value(key = nil, options = {})
        cache = Ramaze::Cache.cache_helper_value

        if key and block_given?
          if found = cache[key]
            found
          else
            cache.store(key, yield, options)
          end
        else
          cache
        end
      end

      module SingletonMethods
        # This method allows you to cache whole actions.
        #
        # @example Basic usage
        #   class Foo < Ramaze::Controller
        #     helper :cache
        #     cache_action :method => :bar
        #
        #     def bar
        #       rand
        #     end
        #   end
        #
        def cache_action(hash, &block)
          hash[:key] = block if block_given?
          hash[:method] = hash[:method].to_s
          trait[:cache_action] << hash
        end
      end
    end # Cache
  end # Helper
end # Ramaze
