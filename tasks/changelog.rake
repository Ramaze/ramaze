desc 'update changelog'
task :changelog do
  File.open('guide/CHANGELOG', 'w+') do |changelog|
    `git log -z --abbrev-commit`.split("\0").each do |commit|
      next if commit =~ /^Merge: \d*/
      ref, author, time, _, title, _, message = commit.split("\n", 7)
      ref    = ref[/commit ([0-9a-f]+)/, 1]
      author = author[/Author: (.*)/, 1].strip
      time   = Time.parse(time[/Date: (.*)/, 1]).utc
      time   = time.strftime('%a %b %d %H:%M:%S %Z %Y')

      title = title.to_s.strip

      changelog.puts "[#{ref} | #{time}] #{author}"
      changelog.puts '', "  * #{title}"
      changelog.puts '', message.rstrip if message
      changelog.puts
    end
  end
end
