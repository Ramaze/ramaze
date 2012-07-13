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
    # @param [Block] block
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
    # @param [Block] block
    #
    def initialize(&block)
      @out = []
      instance_eval(&block) if block_given?
    end

    ##
    # Catching all the tags. passing it to _gestalt_build_tag
    #
    # @param [String] method The method that was called.
    # @param [Hash] args Additional arguments passed to the called method.
    # @param [Block] block
    #
    def method_missing(meth, *args, &block)
      _gestalt_call_tag meth, args, &block
    end

    ##
    # Workaround for Kernel#p to make <p /> tags possible.
    #
    # @param [Hash] args Extra arguments that should be processed before
    #  creating the paragraph tag.
    # @param [Block] block
    #
    def p(*args, &block)
      _gestalt_call_tag :p, args, &block
    end

    ##
    # Workaround for Kernel#select to make <select></select> work.
    #
    # @param [Hash] args Extra arguments that should be processed before
    #  creating the select tag.
    # @param [Block] block
    #
    def select(*args, &block)
      _gestalt_call_tag(:select, args, &block)
    end

    ##
    # Calls a particular tag based on the specified parameters.
    #
    # @param [String] name
    # @param [Hash] args
    # @param [Block] block
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
    # Shortcut for building tags,
    #
    # @param [String] name
    # @param [Hash] args
    # @param [Block] block
    #
    def tag(name, *args, &block)
      _gestalt_call_tag(name.to_s, args, &block)
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
  end # Gestalt
end # Ramaze
