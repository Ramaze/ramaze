#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'haml/util', 'sass'

Ramaze::App.options.views = 'sass'

class SpecSass < Ramaze::Controller
  map '/'
  provide :css, :Sass

  def style
%{
body
  :margin 1em

  #content
    :text-align center
}
  end
end

class SpecSassOptions < Ramaze::Controller
  map '/options'
  provide :css, :Sass
  trait :sass_options => { :style => :compact }

  def test
%{
body
  margin: 1em

  #content
    font:
      family: monospace
      size: 10pt
}
  end
end

describe Ramaze::View::Sass do
  behaves_like :rack_test

  should 'render inline' do
    got = get('/style.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'
    got.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end

  should 'render from file' do
    got = get('/file.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'
    got.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end

  should 'use sass options' do
    got = get('/options/test.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'
    got.body.should.not =~ /^ +/
  end
end
