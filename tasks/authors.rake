desc 'Update doc/AUTHORS'
task :authors do
  authors = Hash.new(0)

  `git shortlog -nse`.scan(/(\d+)\s(.+)\s<(.*)>$/) do |count, name, email|
    authors[[name, email]] += count.to_i
  end

  File.open('guide/AUTHORS', 'w+') do |io|
    io.puts "Following persons have contributed to #{GEMSPEC.name}."
    io.puts '(Sorted by number of submitted patches, then alphabetically)'
    io.puts ''
    authors.sort_by{|(n,e),c| [-c, n.downcase] }.each do |(name, email), count|
      io.puts("%6d %s <%s>" % [count, name, email])
    end
  end
end
