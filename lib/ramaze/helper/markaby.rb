#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  module Helper
    # Allows you to use some shortcuts for markaby in your Controller.
    module Markaby
      ##
      # Use this inside your controller to directly build Markaby
      # Refer to the Markaby-documentation and testsuite for more examples.
      #
      # @example
      #  mab { h1 "Apples & Oranges"}  #=> "<h1>Apples &amp; Oranges</h1>"
      #  mab { h1 'Apples', :class => 'fruits&floots' }
      #
      def markaby(ivs = {}, helpers = nil, &block)
        builder = ::Markaby::Builder
        builder.extend(Ramaze::Helper::Methods)
        builder.send(:helper, :link)

        iv_hash = {}
        instance_variables.each do |iv|
          key, value = iv.gsub('@', '').to_sym, instance_variable_get(iv)
          iv_hash[key] = value
        end

        builder.new(iv_hash.merge(ivs), helpers, &block).to_s
      end

      alias mab markaby
    end # Markaby
  end # Helper
end # Ramaze
