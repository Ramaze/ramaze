require 'ramaze/gestalt'

module Ramaze
  module View
    ##
    # View adapter that allows you to use Ramaze::Gestalt in your views. See the
    # documentation of Ramaze::Gestalt for more information.
    #
    # @see Ramaze::Gestalt
    #
    module Gestalt
      def self.call(action, string)
        string = action.instance.instance_eval(string) if action.view
        html = [string].join

        return html, 'text/html'
      end
    end # Gestalt
  end # View
end # Ramaze
