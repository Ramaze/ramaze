require 'ramaze/gestalt'

module Ramaze
  module Helper
    # Gestalt is the custom HTML/XML builder for Ramaze, based on a very simple 
    # DSL it will build your markup.
    module Gestalt
      CACHE_G = {}

      def gestalt(&block)
        Ramaze::Gestalt.new(&block)
      end

      def build(&block)
        Ramaze::Gestalt.build(&block)
      end

      def g(meth = nil, view = nil)
        meth ||= caller[0].slice(/`(.*)'?/).gsub(/[\`\']/, '')
        view_name = (self.class.to_s.sub('Controller', '') + 'View').split('::')
        view ||= view_name.inject(Object){ |ns, name| ns.const_get(name) }

        gestalt_class = CACHE_G[view] ||= g_class
        gestalt = gestalt_class.new
        gestalt.extend(view)
        instance_variables.each do |iv|
          gestalt.instance_variable_set(iv, instance_variable_get(iv))
        end
        gestalt.__send__(meth)
        gestalt.to_s
      end

      def g_class
        ancs = self.class.ancestors
        helpers = Ramaze::Helper.constants.map{ |c| Ramaze::Helper.const_get(c)}
        our_helpers = ancs & helpers
        our_helpers.delete(Ramaze::Helper::Gestalt)
        gestalt_class = Class.new(Ramaze::Gestalt){ include(*our_helpers) }
      end

      def method_missing(sym, *args, &block)
        @gestalt ||= gestalt
        @gestalt.send(sym, *args, &block)
      end
    end
  end
end

module Ramaze::Helper::Link; undef :a end
