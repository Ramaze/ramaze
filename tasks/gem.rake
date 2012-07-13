namespace :gem do
  desc 'builds the gem and moves it to the pkg/ directory'
  task :build do
    pkg_dir = File.expand_path('../../pkg', __FILE__)

    Dir.mkdir(pkg_dir) if !File.directory?(pkg_dir)

    sh "gem build #{GEMSPEC.name}.gemspec"
    sh "mv #{GEMSPEC.name}-#{GEMSPEC.version}.gem #{pkg_dir}"
  end

  desc "package and install from gemspec"
  task :install => [:build] do
    sh "gem install pkg/#{GEMSPEC.name}-#{GEMSPEC.version}.gem"
  end

  desc "uninstall the gem"
  task :uninstall do
    sh %{gem uninstall -x #{GEMSPEC.name}}
  end
end # namespace :gem
