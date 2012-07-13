Ramaze.setup(:verbose => false) do
  gem 'Remarkably', :lib => 'remarkably'
end

require 'remarkably/engines/html'

module Ramaze
  module View
    module Remarkably
      def self.call(action, string)
        string = transform_string(action, string) if action.view
        html = string.to_s

        return html, 'text/html'
      end

      def self.transform_string(action, string)
        action.instance.instance_eval do
          args = action.params
          instance_eval(string)
        end
      end
    end
  end
end
