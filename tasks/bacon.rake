desc 'Run all bacon specs with pretty output'
task :bacon => :setup do
  require 'open3'
  require 'scanf'
  require 'matrix'
  require 'pathname'

  specs       = PROJECT_SPECS
  some_failed = false
  root_path   = Pathname.new(File.expand_path('../../', __FILE__))

  # Generate a hash of relative and absolute paths for all the specs.
  specs_relative = {}

  specs.each do |spec|
    specs_relative[spec] = Pathname.new(spec).relative_path_from(root_path).to_s
  end

  specs_size  = specs.size
  len         = specs_relative.map { |abs, rel| rel.size }.sort.last
  total_tests = total_assertions = total_failures = total_errors = 0
  totals      = Vector[0, 0, 0, 0]

  red, yellow, green = "\e[31m%s\e[0m", "\e[33m%s\e[0m", "\e[32m%s\e[0m"
  left_format = "%4d/%d: %-#{len + 11}s"
  spec_format = "%d specifications (%d requirements), %d failures, %d errors"

  load_path = File.expand_path('../../lib', __FILE__)

  specs.each_with_index do |spec, idx|
    print(left_format % [idx + 1, specs_size, specs_relative[spec]])

    Open3.popen3(FileUtils::RUBY, '-I', load_path, spec) do |sin, sout, serr|
      out = sout.read.strip
      err = serr.read.strip

      # this is conventional
      if out =~ /^Bacon::Error: (needed .*)/
        puts(yellow % ("%6s %s" % ['', $1]))
      elsif out =~ /^Spec (precondition: "[^"]*" failed)/
        puts(yellow % ("%6s %s" % ['', $1]))
      elsif out =~ /^Spec require: "require" failed: "(no such file to load -- [^"]*)"/
        puts(yellow % ("%6s %s" % ['', $1]))
      else
        total = nil

        out.each_line do |line|
          scanned = line.scanf(spec_format)

          next unless scanned.size == 4

          total = Vector[*scanned]
          break
        end

        if total
          totals += total
          tests, assertions, failures, errors = total_array = total.to_a

          if tests > 0 && failures + errors == 0
            puts((green % "%6d passed") % tests)
          else
            some_failed = true
            puts(red % "       failed")
            puts out unless out.empty?
            puts err unless err.empty?
          end
        else
          some_failed = true
          puts(red % "       failed")
          puts out unless out.empty?
          puts err unless err.empty?
        end
      end
    end
  end

  total_color = some_failed ? red : green
  puts(total_color % (spec_format % totals.to_a))
  exit 1 if some_failed
end
