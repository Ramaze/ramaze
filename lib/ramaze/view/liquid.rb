#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.
Ramaze.setup(:verbose => false) do
  require 'liquid'
end

module Ramaze
  module View
    # Liquid is a smarty-style templating engine that restricts the usage of
    # code inside templates. This is mostly helpful if you want to let users
    # submit templates but prevent them from running arbitrary code.
    #
    # Liquid offers a pipe-like syntax for chaining operations on objects.
    # Any instance variable from your Controller is available as a variable
    # inside Liquid, so be sensitive about what data you provide.
    #
    # If you want to allow partials you can provide a kind of virtual
    # filesystem that contains partials. These can be rendered using the
    # Liquid `{% include 'name' %}` tag. The include tag has no relation to the
    # Ramaze::Helper::Render, it simply inlines the file.
    #
    # To tell Liquid where to find partials, you have to set the file_system.
    # The naming-convention for liquid-partials is to use a '_' prefix to the
    # filename and the '.liquid' filename extension. The names of partials
    # are restricted to ASCII alpha-numeric characters and underscores. You
    # can also use '/' to use templates located in deeper directories.
    # The partial has access to the same variables as the template including
    # it.
    #
    # @example setting file_system
    #   template_path = './partials/'
    #   Liquid::Template.file_system = Liquid::LocalFileSystem.new(template_path)
    #
    # @example using include
    #   {% include 'foo' %}
    #   {% include 'bar/foo' %}
    #
    # This will include the files located at './partials/_foo.liquid' and
    # './partials/bar/_foo.liquid'.
    #
    # This functionality gets even more interesting if you customize it with
    # your own virtual file-system, you can use anything that responds to
    # `#read_template_file(path)`.
    # That way you can even fetch templates from a database or instruct Liquid
    # to allow you access to your own templates in the '/views' directory.
    module Liquid

      # Liquid requires the variable keys to be strings, most likely for
      # security resons (don't allow arbitrary symbols).
      def self.call(action, string)
        action.sync_variables(action)
        variables = {}
        action.variables.each{|k,v| variables[k.to_s] = v }

        liquid = View.compile(string){|s| ::Liquid::Template.parse(s) }
        html = liquid.render(variables)

        return html, 'text/html'
      end

      class Tag < ::Liquid::Tag
        def initialize(tag_name, arg, tokens)
          super
          @arg = arg.strip
        end
      end

      # Liquid has intentionally? no support for binding, in order to use
      # helpers you have to register them as tags.
      #
      # Creating a tag needs boilerplate, so we reduce that for your
      # convenience.
      #
      # This is not the most performant way, it seems like Liquid uses
      # initialize to compile templates and gives you the chance to process the
      # arguments to the tag only once, but if you want that please contribute.
      #
      # Further below are a couple of tags that map to the most common helpers,
      # this also needs contribution as I simply don't have the time to write
      # all of that and invent a consistent syntax.
      def self.register_tag(name, helper, &block)
        klass = Class.new(Tag)
        klass.send(:include, helper)
        klass.send(:define_method, :render, &block)

        ::Liquid::Template.register_tag(name, klass)
      end

      # {% route index %}
      register_tag('route', Ramaze::Helper::Link) do |context|
        Ramaze::Current.action.node.route(@arg)
      end

      # {% anchor "The index" index %}
      register_tag('anchor', Ramaze::Helper::Link) do |context|
        @arg =~ /^(['"])(.*?)\1\s+(.*)/
        Ramaze::Current.action.node.anchor($2, $3)
      end
    end # Liquid
  end # View
end # Ramaze
