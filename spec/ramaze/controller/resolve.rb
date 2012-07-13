#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

class MainController < Ramaze::Controller
  map '/'

  define_method('file.ext'){ 'file.ext' }
  define_method('css__file.css'){ 'file.css' }
  define_method('path__to__js__file.js'){ 'file.js' }
  define_method('other__greet__other'){ @greet = 'hi' }
end

describe 'Controller resolving' do
  behaves_like :rack_test

  it 'should work with .' do
    get('/file.ext').body.should == 'file.ext'
  end

  it 'should work with /' do
    get('/css/file.css').body.should == 'file.css'
    get('/path/to/js/file.js').body.should == 'file.js'
  end

  it 'should find templates' do
    get('/other/greet/other').body.should == '<html>Other: hi</html>'
  end
end
