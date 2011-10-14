module Ramaze
  module Helper

    # Provides shortcuts to the link/script tags.
    ##
    # The XHTML helper can be used for generating CSS and Javascript tags.
    # Generating a CSS tag can be done by calling the css() method:
    #
    #     css 'reset', 'screen', :only => 'ie'
    #
    # This would result in a stylesheet named "reset.css" being loaded only when
    # the user is using Internet Explorer.
    #
    module XHTML
      LINK_TAG = '<link href=%p media=%p rel="stylesheet" type="text/css" />'
      SCRIPT_TAG = '<script src=%p type="text/javascript"></script>'

      ##
      # Generate a CSS tag based on the name, media type and a hash containing
      # additional options. For example, if we want to load the stylesheet only
      # when the user is using Internet Explorer we would have to add a key
      # 'only' with a value of 'ie' to the hash.
      #
      # @param [String] name The name of the CSS file to load.
      # @param [String] media The media type for which the stylesheet should be
      #  loaded.
      # @param [Hash] options A hash containing additional options for the
      #  stylesheet tag.
      # @example
      #   # A very basic example.
      #   css 'reset'
      #
      #   # Oh shiny, IE only
      #   css 'reset', 'screen', :only => 'ie'
      #
      # @return [String] String containing the stylesheet tag.
      #
      def css(name, media = 'screen', options = {})
        if media.respond_to?(:keys)
          options = media
          media = 'screen'
        end

        if only = options.delete(:only) and only.to_s == 'ie'
          "<!--[if IE]>#{css(name, media, options)}<![endif]-->"
        else
          if name =~ /^http/
            LINK_TAG % [name, media]
          else
            prefix = options[:prefix] || 'css'
            LINK_TAG % [
              "#{Ramaze.options.prefix.chomp("/")}/#{prefix}/#{name}.css",
              media
            ]
          end
        end
      end

      ##
      # The css_for method can be used when you want to load multiple
      # stylesheets and don't want to call the css() method over and over
      # again.
      #
      # @example
      #   # This is pretty basic
      #   css_for 'reset', '960', 'style'
      #
      #   # Loading multiple stylesheets with custom options
      #   css_for ['reset', 'print'], ['960', 'print']
      #
      # @see css()
      # @param [Array] args An array containing either the names of all
      #  stylesheets to load or a collection of arrays of which each array
      #  defines the name, media and additional parameters.
      # @return [String]
      #
      def css_for(*args)
        args.map{|arg| css(*arg) }.join("\n")
      end

      ##
      # Generates a Javascript tag that loads an external Javascript file. This
      # tag can't be used for loading inline Javascript files.
      #
      # @example
      #   # Simple isn't it?
      #   js 'jquery'
      #
      #   # Let's change the directory to "some_other_directory"
      #   js 'jquery', :prefix => 'some_other_directory'
      #
      # @param [String] name The name of the Javascript file that should be
      #  loaded.
      # @param [Hash] options Hash that can contain a :prefix key that defines
      #  the directory in which the JS file is located. By default this key is
      #  set to "js".
      # @return [String]
      #
      def js(name, options={})
        if name =~ /^http/ # consider it external full url
          SCRIPT_TAG % name
        else
          SCRIPT_TAG % "#{Ramaze.options.prefix.chomp("/")}/#{options[:prefix] || 'js'}/#{name}.js"
        end
      end

      ##
      # Generate multiple Javascript tags using the js() method.
      #
      # @example
      #   # Pretty simple isn't it?
      #   js_for 'jquery', 'application', 'jquery.gritter'
      #
      # @param [Array] args Array containing the Javascript files to load.
      # @return [String]
      #
      def js_for(*args)
        args.map{|arg| js(*arg) }.join("\n")
      end
    end # XHTML
  end # Helper
end # Ramaze
