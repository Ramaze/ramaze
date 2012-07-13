Ramaze.setup(:verbose => false) do
  gem 'ezamar'
end

module Ramaze
  module View
    ##
    # View adapter for the Ezamar template engine. More information about this
    # engine can be found here: https://github.com/manveru/ezamar
    #
    module Ezamar
      TRANSFORM_PIPELINE = [ ::Ezamar::Element ]

      def self.call(action, string)
        ezamar = View.compile(string){|s| compile(action, s) }
        html = ezamar.result(action.binding)
        return html, 'text/html'
      end

      def self.compile(action, template)
        file = action.view || __FILE__

        TRANSFORM_PIPELINE.each{|tp| template = tp.transform(template) }

        ::Ezamar::Template.new(template, :file => file)
      end
    end # Ezamar
  end # View
end # Ramaze
