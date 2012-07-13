Ramaze.setup(:verbose => false) do
  gem 'lokar'
end

module Ramaze
  module View
    ##
    # Allows views to use Lokar as the template engine. See the following
    # website for more information: https://github.com/Zoxc/Lokar
    #
    module Lokar
      def self.call(action, string)
        compiled = View.compile(string){|s| ::Lokar.compile(s, action.view || __FILE__) }
        html = action.instance.instance_eval(&compiled).join

        return html, 'text/html'
      end
    end # Helper
  end # View
end # Ramaze
