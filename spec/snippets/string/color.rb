#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe 'String#color' do
  it 'should define methods to return ANSI strings' do
    %w[reset bold dark underline blink negative
    black red green yellow blue magenta cyan white].each do |m|
      "string".respond_to? m
      "string".send(m).should.match(/\e\[\d+mstring\e\[0m/)
    end
  end
end
