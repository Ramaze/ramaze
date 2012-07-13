#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'tenjin'

Ramaze::App.options.views = 'tenjin'

class SpecTenjin < Ramaze::Controller
  map '/'
  engine :Tenjin

  def index
    '<h1>Tenjin Index</h1>'
  end

  def links
    '<ul>
      <li><a href="#{r(:index)}">Index page</a></li>
      <li><a href="#{r(:internal)}">Internal template</a></li>
      <li><a href="#{r(:external)}">External template</a></li>
    </ul>'.ui
  end

  def sum(num1, num2)
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

describe 'Ramaze::View::Tenjin' do
  behaves_like :rack_test

  should 'render' do
    get('/').body.should == '<h1>Tenjin Index</h1>'
  end

  should 'use other helper methods' do
    get('/links').body.strip.
      should == '<ul>
  <li><a href="/index">Index page</a></li>
  <li><a href="/internal">Internal template</a></li>
  <li><a href="/external">External template</a></li>
</ul>'
  end

  should 'render external template' do
    get('/external').body.strip.
    should == '<html>
  <head>
    <title>Tenjin Test</title>
  </head>
  <body>
    <h1>Tenjin Template</h1>
  </body>
</html>'
  end
end
