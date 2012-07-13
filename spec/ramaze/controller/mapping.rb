#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

describe 'Controller::generate_mapping' do
  def gen(klass)
    Ramaze::Controller::generate_mapping(klass)
  end

  it 'maps ::ClassController to /class' do
    gen('ClassController').should == '/class'
  end

  it 'maps ::CamelCaseController to /camel_case' do
    gen('CamelCaseController').should == '/camel_case'
  end

  it 'maps Module::ClassController to /module/class' do
    gen('Module::ClassController').should == '/module/class'
  end

  it 'maps Module::MainController to /module/' do
    gen('Module::MainController').should == '/module/'
  end

  it 'maps Class to /class' do
    gen('Class').should == '/class'
  end

  it 'maps Module::Class to /module/class' do
    gen('Module::Class').should == '/module/class'
  end

  it 'maps Module::Module::Class to module/module/class' do
    gen('Module::Module::Class').should == '/module/module/class'
  end

  it 'maps Module::Module::MainController to module/module/' do
    gen('Module::Module::MainController').should == '/module/module/'
  end

  it "maps MainController to '/'" do
    gen('MainController').should == '/'
  end

  it "doesn't map ::Controller" do
    gen('Controller').should == nil
  end

  it "doesn't map Module::Controller" do
    gen('Module::Controller').should == nil
  end

  it "doesn't map anonymous classes" do
    gen(Class.new.name).should == nil
  end

  it "respects custom irregular mappings" do
    Ramaze::Controller::IRREGULAR_MAPPING['Snake'] = 'snake_on_a_plane'
    gen('Some::Snake').should == '/some/snake_on_a_plane'
  end
end
