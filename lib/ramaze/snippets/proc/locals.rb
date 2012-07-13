module Ramaze
  module CoreExtensions
    # Extensions for Proc
    module Proc
      ##
      # Returns a hash of localvar/localvar-values from proc, useful for
      # template engines that do not accept bindings/proc and force passing
      # locals via hash
      #
      # Usage:
      #
      #     x = 42; p Proc.new.locals #=> {'x'=> 42}
      #
      def locals
        instance_eval('binding').locals
      end
    end # Proc
  end # CoreExtensions
end # Ramaze
