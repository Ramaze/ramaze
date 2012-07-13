desc 'Generate YARD documentation of Ramaze (optionally including Innate)'
task :yard, :innate do |task, args|
  path   = File.expand_path('../../doc', __FILE__)
  innate = nil

  # Include Innate
  if args[:innate] and File.directory?(args[:innate])
    innate = File.join(File.expand_path(args[:innate]), '**', '*')
  end

  sh("rm -rf #{path}")
  sh("yard doc #{innate}")
end
