#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../spec/helper', __FILE__)

class SpecFilesCore < Ramaze::Controller
  map '/', :core
end

class SpecFilesOther < Ramaze::Controller
  map '/', :other
end

Ramaze::App[:core].location = '/'
Ramaze::App[:core].options.publics = 'files/public_1'

Ramaze::App[:other].location = '/other'
Ramaze::App[:other].options.publics = 'files/public_2'

Ramaze.middleware!(:spec){|m| m.run(Ramaze::AppMap) }

describe Ramaze::Files do
  behaves_like :rack_test

  it 'serves files for core app from public_1' do
    get('/plain.txt').body.should == "Just some text in a file\n"
  end

  it 'serves files for other app from public_2' do
    get('/other/rich.txt').body.should == "Some rich text in here\n"
  end
end
