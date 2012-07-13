#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/xhtml'

describe Ramaze::Helper::XHTML do
  extend Ramaze::Helper::XHTML

  should 'answer with <link> on #css' do
    css(:foo).
      should == '<link href="/css/foo.css" media="screen" rel="stylesheet" type="text/css" />'
    css(:foo, 'mobile').
      should == '<link href="/css/foo.css" media="mobile" rel="stylesheet" type="text/css" />'
    css(:foo, 'screen', :only => :ie).
      should == '<!--[if IE]><link href="/css/foo.css" media="screen" rel="stylesheet" type="text/css" /><![endif]-->'
    css('http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.js', 'screen').
      should == '<link href="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.js" media="screen" rel="stylesheet" type="text/css" />'
  end

  should 'answer with <link> on #css with optional prefix' do
    css(:foo, 'screen', :prefix => 'bar').
      should == '<link href="/bar/foo.css" media="screen" rel="stylesheet" type="text/css" />'
  end

  should 'answer with <link> on #css with options hash as second argument' do
    css(:foo, :prefix => 'bar/baz').
      should == '<link href="/bar/baz/foo.css" media="screen" rel="stylesheet" type="text/css" />'
  end

  should 'answer with <script> on #js' do
    js(:foo).
      should == '<script src="/js/foo.js" type="text/javascript"></script>'
    js('http://example.com/foo.js').
      should == '<script src="http://example.com/foo.js" type="text/javascript"></script>'
  end

  should 'answer with <script> on #js with optional prefix' do
    js(:foo, :prefix => 'bar').
      should == '<script src="/bar/foo.js" type="text/javascript"></script>'
    js(:foo, :prefix => 'javascripts/deeply/nested').
      should == '<script src="/javascripts/deeply/nested/foo.js" type="text/javascript"></script>'
  end

  should 'answer with multiple <link> on #css_for' do
    css_for(:foo, :bar).
      should == "<link href=\"/css/foo.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n<link href=\"/css/bar.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
  end

  should 'ansewr with multiple <script> on #js_for' do
    js_for(:foo, :bar).
      should == "<script src=\"/js/foo.js\" type=\"text/javascript\"></script>\n<script src=\"/js/bar.js\" type=\"text/javascript\"></script>"
  end
end
