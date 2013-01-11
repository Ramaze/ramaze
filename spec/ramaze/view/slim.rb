require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'slim'

Ramaze::App.options.views = 'slim'

class SpecSlim < Ramaze::Controller
  map '/'
  engine :slim

  def index
    @value = 'foo'

    return 'h1 Slim index with #{@value}'
  end

  def external_vars
    @name = 'Slim'
  end
end # SpecSlim

describe 'Ramaze::View::Slim' do
  behaves_like :rack_test

  should 'render an inline template' do
    got = get('/')

    got.body.should            == '<h1>Slim index with foo</h1>'
    got.status.should          == 200
    got['Content-Type'].should == 'text/html'
  end

  should 'render an external template' do
    got = get('/external')

    got.status.should          == 200
    got['Content-Type'].should == 'text/html'
    got.body.should == '<html><head><title>Slim Template</title></head>' \
      '<body><p>External Slim template</p></body></html>'
  end

  should 'render an external template with variables' do
    got = get('/external_vars')

    got.status.should          == 200
    got['Content-Type'].should == 'text/html'
    got.body.should == '<html><head><title>Slim Template</title></head>' \
      '<body><p>External Slim template</p></body></html>'
  end
end
