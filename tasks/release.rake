desc 'Release on rubygems'
task :release => [:authors, 'gem:build'] do
  name, version = GEMSPEC.name, GEMSPEC.version

  puts <<-INSTRUCTIONS
To publish to Rubygems do following:
  $ gem push pkg/#{GEMSPEC.name}-#{GEMSPEC.version}.gem
  INSTRUCTIONS
end
