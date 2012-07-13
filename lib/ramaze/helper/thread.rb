#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  module Helper
    module Thread
      ##
      # The thread method executes the specified block in a new thread.
      #
      # @param [Block] block The block that contains the code that will be 
      #  executed in the new thread.
      #
      def thread &block
        parent_thread = Thread.current
        Thread.new do
          begin
            block.call
          rescue Exception => e
            parent_thread.raise(e)
          end
        end
      end
    end # Thread
  end # Helper
end # Ramaze
