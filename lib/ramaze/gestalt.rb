#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  ##
  # Gestalt is the custom HTML/XML builder for Ramaze, based on a very simple
  # DSL it will build your markup.
  #
  # @example
  #   html =
  #     Gestalt.build do
  #       html do
  #         head do
  #           title "Hello, World!"
  #         end
  #         body do
  #           h1 "Hello, World!"
  #         end
  #       end
  #     end
  #
  class Gestalt
    attr_accessor :out

    ##
    # The default way to start building your markup.
    # Takes a block and returns the markup.
    #
    # @param [Proc] block
    #
    def self.build(&block)
      self.new(&block).to_s
    end

    ##
    # Gestalt.new is like ::build but will return itself.
    # you can either access #out or .to_s it, which will
    # return the actual markup.
    #
    # Useful for distributed building of one page.
    #
    # @param [Proc] block
    #
    def initialize(&block)
      @out = []
      instance_eval(&block) if block_given?
    end

    ##
    # Catching all the tags. passing it to _gestalt_build_tag
    #
    # @param [String] meth The method that was called.
    # @param [Hash] args Additional arguments passed to the called method.
    # @param [Proc] block
    #
    def method_missing(meth, *args, &block)
      _gestalt_call_tag meth, args, &block
    end

    ##
    # Workaround for Kernel#p to make <p /> tags possible.
    #
    # @param [Hash] args Extra arguments that should be processed before
    #  creating the paragraph tag.
    # @param [Proc] block
    #
    def p(*args, &block)
      _gestalt_call_tag :p, args, &block
    end

    ##
    # Workaround for @g.table in BlueForm using method/call.
    # This is needed in order to use m = g.method("table") etc.
    #
    def table(*args, &block)
      _gestalt_call_tag :table, args, &block
    end

    ##
    # Workaround for @g.tr in BlueForm using method/call.
    # This is needed in order to use m = g.method("tr") etc.
    #
    def tr(*args, &block)
      _gestalt_call_tag :tr, args, &block
    end

    ##
    # Workaround for @g.th in BlueForm using method/call.
    # This is needed in order to use m = g.method("th") etc.
    #
    def th(*args, &block)
      _gestalt_call_tag :th, args, &block
    end

    ##
    # Workaround for @g.td in BlueForm using method/call.
    # This is needed in order to use m = g.method("td") etc.
    #
    def td(*args, &block)
      _gestalt_call_tag :td, args, &block
    end

    ##
    # Workaround for Kernel#select to make <select></select> work.
    #
    def select(*args, &block)
      _gestalt_call_tag(:select, args, &block)
    end

    ##
    # Calls a particular tag based on the specified parameters.
    #
    # @param [String] name
    # @param [Hash] args
    # @param [Proc] block
    #
    def _gestalt_call_tag(name, args, &block)
      if args.size == 1 and args[0].kind_of? Hash
        # args are just attributes, children in block...
        _gestalt_build_tag name, args[0], &block
      elsif args[1].kind_of? Hash
        # args are text and attributes ie. a('mylink', :href => '/mylink')
        _gestalt_build_tag(name, args[1], args[0], &block)
      else
        # no attributes, but text
        _gestalt_build_tag name, {}, args, &block
      end
    end

    ##
    # Build a tag for `name`, using `args` and an optional block that
    # will be yielded.
    #
    # @param [String] name
    # @param [Hash] attr
    # @param [Hash] text
    #
    def _gestalt_build_tag(name, attr = {}, text = [])
      @out << "<#{name}"
      @out << attr.map{|(k,v)| %[ #{k}="#{_gestalt_escape_entities(v)}"] }.join
      if text != [] or block_given?
        @out << ">"
        @out << _gestalt_escape_entities([text].join)
        if block_given?
          text = yield
          @out << text.to_str if text != @out and text.respond_to?(:to_str)
        end
        @out << "</#{name}>"
      else
        @out << ' />'
      end
    end

    ##
    # Replace common HTML characters such as " and < with their entities.
    #
    # @param [String] s The HTML string that needs to be escaped.
    #
    def _gestalt_escape_entities(s)
      s.to_s.gsub(/&/, '&amp;').
        gsub(/"/, '&quot;').
        gsub(/'/, '&apos;').
        gsub(/</, '&lt;').
        gsub(/>/, '&gt;')
    end

    ##
    # Shortcut for building tags.
    #
    # @param [String] name
    # @param [Array] args
    # @param [Proc] block
    #
    def tag(name, *args, &block)
      _gestalt_call_tag(name.to_s, args, &block)
    end

		##
    # A way to append text to the output of Gestalt.
    #
    # @param [String] text
    #
    def <<(str)
      @out << str
    end

    ##
    # Convert the final output of Gestalt to a string.
    # This method has the following alias: "to_str".
    #
    # @return [String]
    #
    def to_s
      @out.join
    end
    alias to_str to_s

    ##
    # Method used for converting the results of the Gestalt helper to a
    # human readable string. This isn't recommended for production because
    # it requires much more time to generate the HTML output than to_s.
    #
    # @return [String] The formatted form output
    #
    def to_html
      # Combine the sub-parts to form whole tags or whole in-between texts
      parts = []
      tag = ""
      @out.each do |frag|
        fragment = String.new(frag)
        case
        when fragment[0] == '<'
          if tag.empty?
            tag << fragment
          else
            parts << tag
            tag = fragment
          end
        when fragment[-1] == '>'
          tag << fragment
          parts << tag
          tag = ""
        else
          tag << fragment
        end # case
      end
      parts << tag if tag
      # output the segments, but adjust the indentation
      indent = 0
      html = ""
      parts.each do |part|
        case
        when part[0..1] == '</'
          indent -= 1
        end
        html << "#{' '*indent}#{part}\n"%indent
        case
        when (part[0] == '<') && (part[-2..-1] == '/>')
          # self terminating tag -- no change in indent
        when (part[0] == '<') && (part[1] != '/')
          indent += 1
        end
      end
      # return the formatted string
      return html
    end # to_html
    
  end # Gestalt
end # Ramaze
