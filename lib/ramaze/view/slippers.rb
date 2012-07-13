Ramaze.setup(:verbose => false) do
  gem 'slippers'
end

module Ramaze
  module View
    ##
    # View adapter for Slippers, see the website of Slippers for more
    # information: http://starapor.github.com/slippers/
    #
    #
    module Slippers
      def self.call(action, string)
        slippers = View.compile(string) do |s|
          ::Slippers::Engine.new(s, :template_group => template_group(action))
        end

        object_to_render = ::Slippers::BindingWrapper.new(action.instance.binding)
        html             = slippers.render(object_to_render)

        return html, 'text/html'
      end

      private

      def self.template_group(action)
        subtemplates = action.instance.ancestral_trait[:slippers_options] || {}
        missing_template_handler = action.instance.ancestral_trait[
          :slippers_missing_template_handler
        ]
        default_string = action.instance.ancestral_trait[
          :slippers_default_string
        ]

        views = action.instance.options[:views].map do |view|
          "#{action.instance.options[:roots]}/#{view}"
        end

        super_group = ::Slippers::TemplateGroup.new(
          :templates                => subtemplates,
          :missing_template_handler => missing_template_handler,
          :default_string           => default_string
        )

        ::Slippers::TemplateGroupDirectory.new(
          views, :super_group       => super_group,
          :missing_template_handler => missing_template_handler,
          :default_string           => default_string
        )
      end
    end # Slippers
  end # View
end # Ramaze
