#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  module CoreExtensions
    # Extensions for String
    module String
      # convert to snake_case from CamelCase
      #
      # @example
      #  'FooBar'.snake_case # => 'foo_bar'
      #
      def snake_case
        gsub(/\B[A-Z][^A-Z]/, '_\&').downcase.gsub(' ', '_')
      end
    end # String
  end # CoreExtensions
end # Ramaze
