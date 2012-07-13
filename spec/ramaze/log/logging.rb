#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecLogger
  include Ramaze::Logging

  attr_reader :history

  def initialize
    @history = []
  end

  def log(*args)
    @history << args
  end
end

describe Ramaze::Logging do
  @log = SpecLogger.new

  should 'provide #info - which calls #to_s' do
    @log.info('info')
    @log.history.last.should == [:info, 'info']

    @log.info(1, 2)
    @log.history.last(2).should == [[:info, '1'], [:info, '2']]
  end

  should 'provide #debug - which calls #inspect' do
    @log.debug(:debug)
    @log.history.last.should == [:debug, ':debug']
  end

  should 'provide #<< as alias for #debug' do
    @log << :<<
    @log.history.last.should == [:debug, ':<<']
  end

  should 'provide #dev - which calls #inspect' do
    @log.dev(:dev)
    @log.history.last.should == [:dev, ':dev']
  end

  should 'provide #error - which formats exceptions' do
    @log.error(1)
    @log.history.last.should == [:error, '1']

    error = StandardError.new('for spec')
    error.set_backtrace(['line 1', 'line 2'])
    @log.error(error)
    @log.history.last(3).should == [
      [:error, "#<StandardError: for spec>"],
      [:error, "line 1"],
      [:error, "line 2"] ]
  end

  should 'not do anything on #shutdown' do
    @log.shutdown.should == nil
  end

  should 'answer to #debug? for WEBrick' do
    @log.debug?.should == false
  end
end
