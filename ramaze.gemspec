require File.expand_path('../lib/ramaze/version', __FILE__)

path = File.expand_path('../', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ramaze'
  s.version     = Ramaze::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.authors     = ['Michael \'manveru\' Fellinger', 'Yorick Peterse']
  s.email       = ['m.fellinger@gmail.com', 'yorickpeterse@gmail.com']
  s.summary     = 'Ramaze is a simple and modular web framework'
  s.homepage    = 'http://ramaze.net/'
  s.description = s.summary

  s.required_rubygems_version = '>= 1.3.5'
  s.files                     = `cd #{path}; git ls-files`.split("\n").sort
  s.has_rdoc                  = 'yard'
  s.executables               = ['ramaze']

  s.add_dependency 'innate', '>= 2012.12'
  s.add_dependency 'rake'

  s.add_development_dependency 'Remarkably'
  s.add_development_dependency 'bacon'
  s.add_development_dependency 'dalli'
  s.add_development_dependency 'erector'
  s.add_development_dependency 'erubis'
  s.add_development_dependency 'ezamar'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'liquid'
  s.add_development_dependency 'locale'
  s.add_development_dependency 'maruku'
  s.add_development_dependency 'mustache'
  s.add_development_dependency 'rack-contrib'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'redis'
  s.add_development_dependency 'moneta'
  s.add_development_dependency 'sass'
  s.add_development_dependency 'sequel'
  s.add_development_dependency 'slim'
  s.add_development_dependency 'slippers'
  s.add_development_dependency 'tagz'
  s.add_development_dependency 'tenjin'
  s.add_development_dependency 'yard'

  if RUBY_VERSION.to_f >= 1.9
    s.add_development_dependency 'lokar'
  end

  # C extensions don't work reliably on jruby and Travis CI doesn't have them
  # enabled.
  if !RUBY_DESCRIPTION.include?('jruby')
    s.add_development_dependency 'localmemcache'
    s.add_development_dependency 'nokogiri'
    s.add_development_dependency 'rdiscount'
    s.add_development_dependency 'sqlite3'
  end

  # Nagoro doesn't seem to work on Rbx
  if !RUBY_DESCRIPTION.include?('rubinius')
    s.add_development_dependency 'nagoro'
  end
end
