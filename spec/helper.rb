if caller_line = caller.grep(%r!spec/ramaze/!).first
  caller_file = caller_line.split(':', 2).first
  caller_root = File.dirname(caller_file)
  $0          = caller_file
end

require File.expand_path('../../lib/ramaze/spec/bacon', __FILE__)
require File.expand_path('../../lib/ramaze/dependencies', __FILE__)

Ramaze.options.roots = [caller_root] if caller_root

module Ramaze
  BINPATH = __DIR__('../bin/ramaze')
  BIN_APP = __DIR__('ramaze/bin/app')
end
