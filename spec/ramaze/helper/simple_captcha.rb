#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecSimpleCaptcha < Ramaze::Controller
  helper :simple_captcha
  map '/'

  def ask_question
    question = simple_captcha
  end

  def answer_question(with)
    check_captcha(with) ? 'correct' : 'wrong'
  end
end

class SpecCustomCaptcha < SpecSimpleCaptcha
  map '/fish'

  trait :captcha => lambda{
    ["the answer to everything", 42]
  }
end

describe Ramaze::Helper::SimpleCaptcha do
  behaves_like :rack_test

  should 'ask question' do
    get('/ask_question')
    question = last_response.body
    question.should =~ /^\d+ [+-] \d+$/

    lh, m, rh = question.split
    answer = lh.to_i.send(m, rh.to_i)

    get("/answer_question/#{answer}").body.should == 'correct'
  end

  should 'ask custom question' do
    get('/fish/ask_question').body.should == 'the answer to everything'
    get('/fish/answer_question/42').body.should == 'correct'
  end
end
