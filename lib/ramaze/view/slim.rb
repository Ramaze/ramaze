require 'slim'

module Innate
  module View
    module Slim
      def self.call(action, string)
        # is the template chached twice by slim and by View?
        filename = action.view || action.method
        slim = View.compile(string) {|str| 
          :: Slim::Template.new(filename){ str }
        }
        html = slim.render(action.instance)
        return html, Response.mime_type
      end
    end
  end
end
