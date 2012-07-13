#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe 'locals' do
  should 'find locals' do
    a = 1
    b = 2
    binding.locals.should == {'a' => 1, 'b' => 2}
  end
end
