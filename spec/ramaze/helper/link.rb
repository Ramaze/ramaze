#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class SpecHelperLink < Ramaze::Controller
  map '/'
end

class SpecHelperLinkTwo < Ramaze::Controller
  map '/two'
end

class SpecHelperApp < Ramaze::Controller
  map '/', :other
end

class SpecHelperAppTwo < Ramaze::Controller
  map '/two', :other
end

Ramaze::App[:other].location = '/other'

describe Ramaze::Helper::Link do
  extend Ramaze::Helper::Link

  it 'lays out breadcrumbs' do
    SpecHelperLink.breadcrumbs('/file/dir/listing/is/cool').
      should == [
      '<a href="/file">file</a>',
      '<a href="/file/dir">dir</a>',
      '<a href="/file/dir/listing">listing</a>',
      '<a href="/file/dir/listing/is">is</a>',
      '<a href="/file/dir/listing/is/cool">cool</a>'
    ].join('/')
  end

  it 'lays out breadcrumbs with href prefix' do
    SpecHelperLink.breadcrumbs('/file/dir/listing/is/cool', '/', '/', '/prefix/path').
      should == [
      '<a href="/prefix/path/file">file</a>',
      '<a href="/prefix/path/file/dir">dir</a>',
      '<a href="/prefix/path/file/dir/listing">listing</a>',
      '<a href="/prefix/path/file/dir/listing/is">is</a>',
      '<a href="/prefix/path/file/dir/listing/is/cool">cool</a>'
    ].join('/')
  end

  it "builds routes and links to other applications" do
    SpecHelperApp.r(:foo).to_s.should == '/other/foo'
    SpecHelperApp.a(:foo, :bar).should == '<a href="/other/bar">foo</a>'
    SpecHelperAppTwo.r(:foo).to_s.should == '/other/two/foo'
    SpecHelperAppTwo.a(:foo, :bar).should == '<a href="/other/two/bar">foo</a>'
  end
  it "builds routes when Ramaze.options.prefix is present" do
    Ramaze.options.prefix = '/prfx'
    SpecHelperLink.r(:foo).to_s.should == '/prfx/foo'
    SpecHelperLinkTwo.r(:foo).to_s.should == '/prfx/two/foo'
    SpecHelperApp.r(:foo).to_s.should == '/prfx/other/foo'
    SpecHelperAppTwo.r(:foo).to_s.should == '/prfx/other/two/foo'

  end
  it "builds links when Ramaze.options.prefix is present" do
    Ramaze.options.prefix = '/prfx'
    SpecHelperLink.a(:foo, :bar).should == '<a href="/prfx/bar">foo</a>'
    SpecHelperLinkTwo.a(:foo, :bar).should == '<a href="/prfx/two/bar">foo</a>'
    SpecHelperApp.a(:foo, :bar).should == '<a href="/prfx/other/bar">foo</a>'
    SpecHelperAppTwo.a(:foo, :bar).should == '<a href="/prfx/other/two/bar">foo</a>'
  end
end
