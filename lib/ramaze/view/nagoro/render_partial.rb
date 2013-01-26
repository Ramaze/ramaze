require 'innate/helper/render'

module Nagoro
  module Pipe
    # Pipe that transforms <render /> tags.
    #
    # the src parameter in the render tag will be used as first parameter to
    # render_partial, all other parameters are passed on as +variables+.
    #
    # Example calling render_partial('hello'):
    #   <render src="hello" />
    #
    # Example calling render_partial('hello', 'tail' => 'foo'):
    #   <render src="hello" tail="foo" />
    #
    class RenderPartial < Base
      include Innate::Helper::Render

      def tag_start(tag, attrs)
        if tag == 'render' and action_name = attrs.delete('src')
          append(render_partial(action_name, attrs))
        else
          super
        end
      end

      def tag_end(tag)
        super unless tag == 'render'
      end
    end
  end
end
