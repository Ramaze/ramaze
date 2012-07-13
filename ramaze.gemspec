require File.expand_path('../lib/ramaze/version'     , __FILE__)
require File.expand_path('../lib/ramaze/dependencies', __FILE__)

# Get all the files from the manifest
path = File.expand_path('../', __FILE__)

Gem::Specification.new do |s|
  s.name                      = 'ramaze'
  s.version                   = Ramaze::VERSION
  s.date                      = '2012-04-14'
  s.authors                   = ['Michael \'manveru\' Fellinger']
  s.email                     = 'm.fellinger@gmail.com'
  s.summary                   = 'Ramaze is a simple and modular web framework'
  s.homepage                  = 'http://ramaze.net/'
  s.description               = s.summary
  s.required_rubygems_version = '>= 1.3.5'
  s.files                     = `cd #{path}; git ls-files`.split("\n").sort
  s.has_rdoc                  = 'yard'
  s.executables               = ['ramaze']

  Ramaze::DEPENDENCIES.each do |dep|
    s.add_dependency(dep[:name], dep[:version])
  end

  Ramaze::DEVELOPMENT_DEPENDENCIES.each do |dep|
    s.add_development_dependency(dep[:name], dep[:version])
  end
end # Gem::Specification.new
