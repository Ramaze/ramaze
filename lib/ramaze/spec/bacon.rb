begin
  require 'bacon'
rescue LoadError
  require 'rubygems'
  require 'bacon'
end

require File.expand_path('../../../ramaze', __FILE__)
require 'innate/spec/bacon'

def spec_requires(*libs)
  spec_precondition 'require' do
    libs.each { |lib| require(lib) }
  end
end
alias spec_require spec_requires

def spec_precondition(name)
  yield
rescue LoadError => ex
  puts "Spec require: %p failed: %p" % [name, ex.message]
  exit 0
rescue Exception => ex
  puts "Spec precondition: %p failed: %p" % [name, ex.message]
  exit 0
end

# minimal middleware, no exception handling
Ramaze.middleware!(:spec) do |m|
  m.run(Ramaze::AppMap)
end

shared :rack_test do
  Ramaze.setup_dependencies
  extend Rack::Test::Methods

  def app; Ramaze.middleware; end
end

shared :webrat do
  behaves_like :rack_test

  require 'webrat'

  Webrat.configure { |config| config.mode = :rack }

  extend Webrat::Methods
  extend Webrat::Matchers
end

# Ignore log messages
Ramaze::Log.level = Logger::ERROR
