Ramaze.setup(:verbose => false) do
  gem 'tenjin'
end

module Ramaze
  module View
    module Tenjin
      def self.call(action, string)
        tenjin = View.compile(string){|s|
          template = ::Tenjin::Template.new
          template.convert(s)
          template
        }

        html = tenjin.ramaze_render(action.binding)

        return html, 'text/html'
      end
    end
  end
end

module Tenjin
  class Template
    # This method allows us to use tenjin with a binding, so helper methods are
    # available instead of only instance variables.
    # The big issue with this approach is that the original
    # Tenjin::ContextHelper is not available here. Patches welcome.
    def ramaze_render(binding)
      code = "_buf = #{init_buf_expr}; #{@script}; _buf.to_s"
      _buf = eval(code, binding, @filename || '(tenjin)')
    end
  end
end
