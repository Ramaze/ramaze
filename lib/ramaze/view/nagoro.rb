Ramaze.setup(:verbose => false) do
  gem 'nagoro'
end

require 'ramaze/view/nagoro/render_partial'

module Ramaze
  module View
    # Binding to the Nagoro templating engine.
    #
    # To pipe your template through tidy you have to use:
    #
    #   Ramaze::View::Nagoro.options.tidy = true
    #
    # @see http://github.com/manveru/nagoro
    module Nagoro
      include Optioned

      options.dsl do
        o "Pipes to pass the template through",
          :pipes, ::Nagoro::DEFAULT_PIPES

        o "Use tidy to cleanup the rendered template",
          :tidy, false
      end

      def self.call(action, string)
        default_options = {
          :pipes     => options.pipes,
          :filename  => action.view,
          :binding   => action.binding,
          :variables => action.variables
        }

        render_options = default_options.merge(action.options)

        if options.tidy
          html = ::Nagoro.tidy_render(string.to_s, render_options)
        else
          html = ::Nagoro.render(string.to_s, render_options)
        end

        return html, 'text/html'
      end
    end # Nagoro
  end # View
end # Ramaze
