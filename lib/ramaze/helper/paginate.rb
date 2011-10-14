require 'ramaze/gestalt'

module Ramaze
  module Helper
    # Helper for pagination and pagination-navigation.
    #
    # See {Ramaze::Helper::Paginate#paginate} for more information.
    #
    module Paginate
      include Traited

      # Define default options in your Controller, they are being retrieved by
      # ancestral_trait, so you can also put it into a common superclass
      trait :paginate => {
        :limit => 10,
        :var   => 'pager',
      }

      ##
      # Returns a new Paginator instance.
      #
      # Note that the pagination relies on being inside a Ramaze request to
      # gain necessary metadata about the page it resides on, you cannot use it
      # outside of Ramaze yet.
      #
      # The examples below are meant to be used within your controller or view.
      #
      # Usage with Array:
      #
      #     data = (1..100).to_a
      #     @pager = paginate(data, :limit => 30, :page => 2)
      #     @pager.navigation
      #     @pager.each{|e| puts(e) }
      #
      # Usage with Sequel:
      #
      #     data = Article.filter(:public => true)
      #     @pager = paginate(data, :limit => 5)
      #     @pager.navigation
      #     @pager.each{|e| puts(e)
      #
      # Note that you must first extend Sequel with the pagination extension"
      #
      #
      #     Sequel.extension :pagination
      #
      # @param [Sequel::Dataset|Array] dataset May be a Sequel dataset or an
      #  Array
      # @param [Hash] options A hash containing custom options that takes
      #  precedence to ``trait[:paginate].
      # @option options [Fixnum] :limit The number of elements used when you
      #  call #each on the paginator
      # @option options [String] :var The variable name being used in the
      #  request, this is helpful if you want to use two or more independent
      #  paginations on the same page.
      # @option options [Fixnum] :page The page you are currently on, if not
      #  given it will be retrieved from current request variables. Defaults to
      #  1 if neither exists.
      #
      def paginate(dataset, options = {})
        options = ancestral_trait[:paginate].merge(options)
        limit = options[:limit]
        var   = options[:var]
        page  = options[:page] || (request[var] || 1).to_i

        Paginator.new(dataset, page, limit, var)
      end

      # Provides easy pagination and navigation
      class Paginator
        include Ramaze::Helper
        helper :link, :cgi

        def initialize(data = [], page = 1, limit = 10, var = 'pager')
          @data, @page, @limit, @var = data, page, limit, var
          @pager = pager_for(data)
          @page = @page > page_count ? page_count : @page
          @pager = pager_for(data)
        end

        ##
        # Returns String with navigation div.
        #
        # This cannot be customized very nicely, but you can style it easily
        # with CSS.
        #
        # Output with 5 elements, page 1, limit 3:
        #
        #     <div class="pager">
        #       <span class="first grey">&lt;&lt;</span>
        #       <span class="previous grey">&lt;</span>
        #       <a class="current" href="/index?pager=1">1</a>
        #       <a href="/index?pager=2">2</a>
        #       <a class="next" href="/index?pager=2">&gt;</a>
        #       <a class="last" href="/index?pager=2">&gt;&gt;</a>
        #     </div>
        #
        # Output with 5 elements, page 2, limit 3:
        #
        #     <div class="pager" />
        #       <a class="first" href="/index?user_page=1">&lt;&lt;</a>
        #       <a class="previous" href="/index?user_page=1">&lt;</a>
        #       <a href="/index?user_page=1">1</a>
        #       <a class="current" href="/index?user_page=2">2</a>
        #       <span class="next grey">&gt;</span>
        #       <span class="last grey">&gt;&gt;</span>
        #     </div>
        #
        def navigation(limit = 8)
          g = Ramaze::Gestalt.new
          g.div :class => :pager do
            if first_page?
              g.span(:class => 'first grey'){ h('<<') }
              g.span(:class => 'previous grey'){ h('<') }
            else
              link(g, 1, '<<', :class => :first)
              link(g, prev_page, '<', :class => :previous)
            end

            lower = limit ? (current_page - limit) : 1
            lower = lower < 1 ? 1 : lower

            (lower...current_page).each do |n|
              link(g, n)
            end

            link(g, current_page, current_page, :class => :current)

            if last_page?
              g.span(:class => 'next grey'){ h('>') }
              g.span(:class => 'last grey'){ h('>>') }
            elsif next_page
              higher = limit ? (next_page + limit) : page_count
              higher = [higher, page_count].min
              (next_page..higher).each do |n|
                link(g, n)
              end

              link(g, next_page, '>', :class => :next)
              link(g, page_count, '>>', :class => :last)
            end
          end
          g.to_s
        end

        # Useful to omit pager if it's of no use.
        def needed?
          @pager.page_count > 1
        end

        # these methods are actually on the pager, but we def them here for
        # convenience (method_missing in helper is evil and even slower)
        def page_count  ; @pager.page_count  ; end
        def each(&block); @pager.each(&block); end
        def first_page? ; @pager.first_page? ; end
        def prev_page   ; @pager.prev_page   ; end
        def current_page; @pager.current_page; end
        def last_page   ; @pager.last_page   ; end
        def last_page?  ; @pager.last_page?  ; end
        def next_page   ; @pager.next_page   ; end
        def empty?      ; @pager.empty?      ; end
        def count       ; @pager.count       ; end

        private

        def pager_for(obj)
          @page = @page < 1 ? 1 : @page

          case obj
          when Array
            ArrayPager.new(obj, @page, @limit)
          when (defined?(DataMapper::Collection) and DataMapper::Collection)
            DataMapperPager.new(obj, @page, @limit)
          else
            obj.paginate(@page, @limit)
          end
        end

        def link(g, n, text = n, hash = {})
          text = h(text.to_s)

          action = Current.action
          params = request.params.merge(@var.to_s => n)
          hash[:href] = action.node.r(action.path, params)

          g.a(hash){ text }
        end

        # Wrapper for Array to behave like the Sequel pagination
        class ArrayPager
          def initialize(array, page, limit)
            @array, @page, @limit = array, page, limit
            @page = page_count if @page > page_count
          end

          def size
            @array.size
          end

          def empty?
            @array.empty?
          end

          def page_count
            pages, rest = size.divmod(@limit)
            rest == 0 ? pages : pages + 1
          end

          def current_page
            @page
          end

          def next_page
            page_count == @page ? nil : @page + 1
          end

          def prev_page
            @page <= 1 ? nil : @page - 1
          end

          def first_page?
            @page <= 1
          end

          def last_page?
            page_count == @page
          end

          def each(&block)
            from = ((@page - 1) * @limit)
            to = from + @limit

            a = @array[from...to] || []
            a.each(&block)
          end

          include Enumerable
        end

        # Wrapper for DataMapper::Collection to behave like the Sequel
        # pagination.
        # needs 'datamapper' (or 'dm-core' and 'dm-aggregates')
        class DataMapperPager < ArrayPager

          def initialize(*args)
            unless defined?(DataMapper::Aggregates)
              Ramaze::Log.warn "paginate.rb: it is strongly " +
                               "recommended to require 'dm-aggregates'"
            end

            super
          end

          def size
            @cached_size ||= @array.count
          end

          def empty?
            size == 0
          end
        end # DataMapperPager
      end # Paginator
    end # Paginate
  end # Helper
end # Ramaze
