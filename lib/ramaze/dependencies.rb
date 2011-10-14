module Ramaze
  # Array containing the names and versions of all the gems required by Ramaze
  # along with the name of how the gem should be required.
  DEPENDENCIES = [
    {:name => 'innate', :version => ['>= 2010.03']}
  ]

  # Array containing all the development dependencies.
  DEVELOPMENT_DEPENDENCIES = [
    {:name => 'bacon'       , :version => ['>= 1.1.0']},
    {:name => 'dalli'       , :version => ['>= 1.0.5']},
    {:name => 'erector'     , :version => ['>= 0.8.2']},
    {:name => 'erubis'      , :version => ['>= 2.7.0']},
    {:name => 'ezamar'      , :version => ['>= 2009.06']},
    {:name => 'sass'        , :version => ['>= 3.1.4']},
    {:name => 'haml'        , :version => ['>= 3.1.2']},
    {:name => 'hpricot'     , :version => ['>= 0.8.4']},
    {:name => 'liquid'      , :version => ['>= 2.2.2']},
    {:name => 'locale'      , :version => ['>= 2.0.5']},
    {:name => 'lokar'       , :version => ['>= 0.2.1']},
    {:name => 'maruku'      , :version => ['>= 0.6.0']},
    {:name => 'mustache'    , :version => ['>= 0.99.4']},
    {:name => 'nagoro'      , :version => ['>= 2009.05']},
    {:name => 'rack-contrib', :version => ['>= 1.1.0'], :lib => 'rack/contrib'},
    {:name => 'rack-test'   , :version => ['>= 0.6.0'], :lib => 'rack/test'},
    {:name => 'Remarkably'  , :version => ['>= 0.6.1'], :lib => 'remarkably'},
    {:name => 'sequel'      , :version => ['>= 3.25.0']},
    {:name => 'slippers'    , :version => ['>= 0.0.14']},
    {:name => 'sqlite3'     , :version => ['>= 1.3.3']},
    {:name => 'tagz'        , :version => ['>= 9.0.0']},
    {:name => 'tenjin'      , :version => ['>= 0.6.1']},
    {:name => 'yard'        , :version => ['>= 0.7.2']},
    {:name => 'redis'       , :version => ['>= 2.2.2']},
    {:name => 'rdiscount'   , :version => ['>= 1.6.8']}
  ]

  if !RUBY_PLATFORM.include?('darwin')
    DEVELOPMENT_DEPENDENCIES.push(
      {:name => 'localmemcache', :version => ['>= 0.4.4']}
    )
  end

  if RUBY_PLATFORM.include?('darwin')
    DEVELOPMENT_DEPENDENCIES.push(
      {:name => 'ruby-growl', :version => ['>= 3.0']}
    )
  end
end # Ramaze
