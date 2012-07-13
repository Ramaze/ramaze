require 'remarkably'

module Ramaze
  module Helper
    module Remarkably
      include ::Remarkably::Common

      # Avoid calling the Helper::Link#a method
      def a(*args, &block)
        method_missing(:a, *args, &block)
      end
    end # Remarkably
  end # Helper
end # Ramaze
