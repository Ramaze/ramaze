#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'erubis'

Ramaze::App.options.views = 'erubis'

class SpecErubis < Ramaze::Controller
  map '/'
  engine :Erubis

  def index
    '<h1>Erubis Index</h1>'
  end

  def links
    '<ul>
      <li><%= a("Index page", :index) %></li>
      <li><%= a("Internal template", :internal) %></li>
      <li><%= a("External template", :external) %></li>
    </ul>'.ui
  end

  def sum(num1, num2)
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

describe "Ramaze::View::Erubis" do
  behaves_like :rack_test

  should 'render' do
    got = get('/')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "<h1>Erubis Index</h1>"
  end

  should 'use other helper methods' do
    got = get('/links')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
'<ul>
  <li><a href="/index">Index page</a></li>
  <li><a href="/internal">Internal template</a></li>
  <li><a href="/external">External template</a></li>
</ul>'
  end

  should 'render external template' do
    got = get('/external')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
"<html>
  <head>
    <title>Erubis Test</title>
  </head>
  <body>
    <h1>Erubis Template</h1>
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
