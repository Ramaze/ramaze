require File.expand_path('../../lib/ramaze/setup', __FILE__)

desc 'install all possible dependencies'
task :setup do
  Ramaze.setup(:verbose => false) do
    deps = Ramaze::DEPENDENCIES + Ramaze::DEVELOPMENT_DEPENDENCIES

    deps.each do |dep|
      if dep[:setup] != false
        gem(dep[:name], dep[:version], :lib => dep.delete(:lib))
      end
    end
  end
end # task :setup
