require 'maruku'

module Ramaze
  module Helper
    module Maruku
      # Shortcut to generate HTML from Markdown code using Maruku
      #
      # @param [#to_str] text the markdown to be converted
      # @return [String] html generated from +text+
      # @author manveru
      def maruku(text)
        ::Maruku.new(text.to_str).to_html
      end
    end # Maruku
  end # Helper
end # Ramaze
