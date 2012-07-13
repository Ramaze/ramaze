module Ramaze
  module Helper
    # Produce very simple question/answer pairs.
    #
    # The default is a trivial mathematical problem.
    #
    # Usage (trait is optional):
    #
    #     class RegisterController < Ramaze::Controller
    #       trait :captcha => lambda{
    #         ["the answer to everything", "42"]
    #       }
    #
    #       def index
    #         %(
    #           <form action="#{r(:answer}">
    #             What is #{simple_captcha}?
    #             <input type="text" name="answer" />"
    #             <input type="submit" />
    #           </form>
    #         ).strip
    #       end
    #
    #       def answer
    #         check_captcha(request[:answer])
    #       end
    #     end
    #
    module SimpleCaptcha
      include Ramaze::Traited

      NUMBERS = [5, 10, 15, 20]

      # lambda should return question and answer in [question, answer] form
      trait :captcha => lambda{
        ns = Array.new(2){ NUMBERS.sort_by{rand}.first }.sort
        op = rand > 0.42 ? [ns[0], :+, ns[1]] : [ns[1], :-, ns[0]]

        question = op.join(' ')
        answer   = op[0].send(op[1], op[2])

        [question, answer]
      }

      # Call the trait[:captcha] and store question/answer in session
      def simple_captcha
        question, answer  = ancestral_trait[:captcha].call
        session[:CAPTCHA] = { :question => question, :answer => answer.to_s }

        question
      end

      # check the given +answer+ against the answer stored in the session.
      def check_captcha(answer)
        return false unless captcha = session[:CAPTCHA]

        answer.to_s.strip == captcha[:answer].to_s
      end
    end # SimpleCaptcha
  end # Helper
end # Ramaze
