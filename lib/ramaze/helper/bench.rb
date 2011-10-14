require 'benchmark'

module Ramaze
  module Helper
    ##
    # The Benchmark helper is a simple helper that can be used to benchmark
    # certain blocks of code by wrapping them in a block. This can be useful if
    # you want to see how long a certain query takes or how long it takes to
    # create a new user.
    #
    module Bench
      ##
      # Will first run an empty loop to determine the overhead it imposes, then
      # goes on to yield your block +iterations+ times.
      #
      # The last yielded return value will be returned upon completion of the
      # benchmark and the result of the benchmark itself will be sent to
      # Log.info
      #
      # Example:
      #
      #     class MainController < Ramaze::Controller
      #       def index
      #         @users = bench{ User.all }
      #         @tags = bench{ Article.tags }
      #       end
      #     end
      #
      # This will show something like following in your log:
      #
      #     [..] INFO   Bench ./start.rb:3:in `index': 0.121163845062256
      #     [..] INFO   Bench ./start.rb:4:in `index': 2.234987235098341
      #
      # So now we know that the Article.tags call takes the most time and
      # should be improved.
      #
      # @param  [Fixnum] iterations The amount of iterations to run.
      # @return [Mixed]
      #
      def bench(iterations = 1)
        result = nil
        from   = caller[0]
        delta  = Benchmark.realtime{ iterations.times{ nil }}
        taken  = Benchmark.realtime{ iterations.times{ result = yield }}

        Log.info "Bench #{from}: #{taken - delta}"
        return result
      end
    end # Bench
  end # Helper
end # Ramaze
