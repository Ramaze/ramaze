#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'liquid'

Ramaze::App.options.views = 'liquid'

class SpecLiquid < Ramaze::Controller
  map '/'
  engine :Liquid

  def index
    '<h1>Liquid Index</h1>'
  end

  def links
    '<ul>
      <li>{% anchor "Index page" index %}</li>
      <li>{% anchor "Internal template" internal %}</li>
      <li>{% anchor "External template" external %}</li>
    </ul>'.ui
  end

  def sum(num1, num2)
    @sum = num1.to_i + num2.to_i
  end
end

describe 'Ramaze::View::Liquid' do
  behaves_like :rack_test

  should 'render' do
    got = get('/')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "<h1>Liquid Index</h1>"
  end

  should 'use custom tags for default helpers' do
    got = get('/links')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
    '<ul>
      <li><a href="/index">Index page</a></li>
      <li><a href="/internal">Internal template</a></li>
      <li><a href="/external">External template</a></li>
    </ul>'.ui
  end

  should 'render external template' do
    got = get('/external')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
"<html>
  <head>
    <title>Liquid Test</title>
  </head>
  <body>
    <h1>Liquid Template</h1>
  </body>
</html>"
  end

  should 'render external template with instance variables' do
    got = get('/sum/1/2')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "<div>3</div>"
  end
end
