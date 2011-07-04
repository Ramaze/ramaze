require 'mustache'

module Ramaze
  module View
    # Binding to Mustache templating engine.
    #
    # Mustache uses user-defined class for rendering. Ramaze overwrites value,
    # if controller defined same name variable as method that class defined.
    #
    # @see http://github.com/defunkt/mustache
    module Mustache
      class RamazeContext < ::Mustache::Context
        def escapeHTML(str)
          str.escape(:html)
        end
      end

      def self.call(action, string)
        context, path, ext = class_defined?(action)

        action.sync_variables(action)
        action.variables.each { |k, v| context[k.to_sym] = v }

        view = View.compile(string) { |s| ::Mustache::Template.new(s) }
        html = view.render(context)

        return html, 'text/html'
      end

      def self.class_defined?(action)
        return RamazeContext.new(nil), nil, nil unless action.view

        path = File.dirname(action.view)

        klass = if FileTest.exist?(File.join(path, "#{action.name}.rb"))
          require File.join(path, action.name)
          ::Object.const_get(::Mustache.classify(action.name)) # or eval?
        else
          ::Mustache
        end

        return RamazeContext.new(klass.new), path, View.exts_of(self).first
      end
    end
  end
end
