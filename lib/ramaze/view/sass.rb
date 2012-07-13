Ramaze.setup(:verbose => false) do
  gem 'haml'
  gem 'sass'
end

require 'haml/util'

module Ramaze
  module View
    module Sass
      def self.call(action, string)
        options = action.options

        if sass_options = action.instance.ancestral_trait[:sass_options]
          options = options.merge(sass_options)
        end

        sass = View.compile(string){|s| ::Sass::Engine.new(s, options) }
        css = sass.to_css

        return css, 'text/css'
      end
    end
  end
end
