#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../lib/ramaze/spec/helper/snippets', __FILE__)

describe "String#unindent" do
  it "should remove indentation" do
    %(
      hello
        how
          are
        you
      doing
    ).ui.should == \
%(hello
  how
    are
  you
doing)
  end

  it 'should not break on a single line' do
    'word'.unindent.should == 'word'
  end

  it 'should find the first line with indentation' do
%(  hi
  there
    bob).ui.should == \
%(hi
there
  bob)
  end

  it 'should have destructive version' do
    str = %(  1\n    2\n  3)
    str.ui!
    str.should == %(1\n  2\n3)
  end

  it 'should use indentation from the last line if first line is not indented' do
    %(a{
      abc
    }).ui.should == %(a{\n  abc\n})
  end
end
