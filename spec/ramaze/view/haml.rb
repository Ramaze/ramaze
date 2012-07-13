#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'haml'

Ramaze::App.options.views = 'haml'

class SpecHaml < Ramaze::Controller
  map '/'
  engine :Haml

  def index
    '%h1 Haml Index'
  end

  def links
    '
    %ul
      %li
        %a{:href => r(:index)} Index page
      %li
        %a{:href => r(:internal)} Internal template
      %li
        %a{:href => r(:external)} External template
    '.ui
  end

  def sum(num1, num2)
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

class SpecHamlLayout < Ramaze::Controller
  map '/with_layout'
  engine :Haml
  layout :wrapper

  RUNS = [1,2,3]

  def index
    RUNS.shift.to_s
  end

  def wrapper
    '= @content'
  end
end

describe Ramaze::View::Haml do
  behaves_like :rack_test

  should 'render' do
    got = get('/')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "<h1>Haml Index</h1>"
  end

  should 'use other helper methods' do
    got = get('/links')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
"<ul>
  <li>
    <a href='/index'>Index page</a>
  </li>
  <li>
    <a href='/internal'>Internal template</a>
  </li>
  <li>
    <a href='/external'>External template</a>
  </li>
</ul>"
  end

  should 'render external template' do
    got = get('/external')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
"<html>
  <head>
    <title>Haml Test</title>
  </head>
  <body>
    <h1>Haml Template</h1>
  </body>
</html>"
  end

  should 'render external template with instance variables' do
    got = get('/sum/1/2')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
"<div>
  3
</div>"
  end

  should 'render the wrapped view twice even with caching' do
    got = get('/with_layout')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "1"

    got = get('/with_layout')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "2"
  end
end
