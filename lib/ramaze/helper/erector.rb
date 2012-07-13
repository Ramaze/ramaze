#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'erector'

module Ramaze
  module Helper
    ##
    # Allows you to use some shortcuts for Erector in your Controller.
    #
    # use this inside your controller to directly build Erector
    # Refer to the Erector-documentation and testsuite for more examples.
    #
    # @example
    #   erector { h1 "Apples & Oranges" } #=> "<h1>Apples &amp; Oranges</h1>"
    #   erector { h1(:class => 'fruits&floots'){ text 'Apples' } }
    #
    module Erector
      include ::Erector::Mixin

      class ::Erector::Widget
        alias :raw! :rawtext
        alias :old_css :css

        ##
        # Method that generates a XHTML 1.0 Strict doctype.
        #
        # @example
        #   strict_html do
        #     head do
        #       title "Ramaze Rocks!"
        #     end
        #     body
        #       div do
        #
        #       end
        #     end
        #   end
        #
        # @param [Hash] args Hash containing extra options such as the xml:lang
        #  and xmlns attribute.
        # @param [Block] block Block that contains the inner data of the <html>
        #  element.
        #
        def strict_xhtml(*args, &block)
          raw! '<?xml version="1.0" encoding="UTF-8"?>'
          raw! '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">'
          html(:xmlns => "http://www.w3.org/1999/xhtml", :"xml:lang" => "en", :lang => "en", &block)
        end

        ##
        # Generate a Javascript tag.
        #
        # @example
        #   js 'javascript/jquery.js'
        #
        # @param [String] src The full or relative path to the Javascript file.
        #
        def js(src)
          script :src => src
        end

        ##
        # Generate a pair of conditional tags for a specific browser.
        #
        # @example
        #   ie_if 'IE' do
        #     ......
        #   end
        #
        # @param [String] expr The if expression, such as 'IE' or 'lte IE7'.
        # @param [block] block Block that contains the data that needs to be
        #  loaded for the specified browser.
        #
        def ie_if(expr, &block)
          raw! "<!--[if #{expr}]>"
          yield
          raw! "<![endif]-->"
        end

        ##
        # Inspect the specified element.
        #
        # @param [String] elem The element to inspect.
        #
        def inspect(elem)
          text elem.inspect
        end

        ##
        # Generate a stylesheet tag.
        #
        # @example
        #   css 'css/reset.css', :media => 'print'
        #
        # @param [String] href The path (either absolute or relative) to the CSS
        #  file.
        # @param [Hash] args A hash containing additional arguments to add to
        #  the CSS tag.
        #
        def css(href, args = {})
          attrs = {
            :rel => "stylesheet",
            :href => href,
            :type => "text/css"
          }.merge(args)

          link attrs
        end
      end # Erector::Widget
    end # Erector
  end # Helper
end # Ramaze
