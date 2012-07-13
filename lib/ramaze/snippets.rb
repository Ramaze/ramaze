#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'ramaze/snippets/array/put_within'
require 'ramaze/snippets/binding/locals'
require 'ramaze/snippets/blankslate'
require 'ramaze/snippets/fiber'
require 'ramaze/snippets/kernel/pretty_inspect'
require 'ramaze/snippets/metaid'
require 'ramaze/snippets/numeric/filesize_format'
require 'ramaze/snippets/numeric/time'
require 'ramaze/snippets/object/__dir__'
require 'ramaze/snippets/object/instance_variable_defined'
require 'ramaze/snippets/object/pretty'
require 'ramaze/snippets/object/scope'
require 'ramaze/snippets/ordered_set'
require 'ramaze/snippets/proc/locals'
require 'ramaze/snippets/ramaze/acquire'
require 'ramaze/snippets/ramaze/deprecated'
require 'ramaze/snippets/ramaze/dictionary'
require 'ramaze/snippets/ramaze/fiber'
require 'ramaze/snippets/ramaze/lru_hash'
require 'ramaze/snippets/ramaze/struct'
require 'ramaze/snippets/string/camel_case'
require 'ramaze/snippets/string/color'
require 'ramaze/snippets/string/end_with'
require 'ramaze/snippets/string/esc'
require 'ramaze/snippets/string/ord'
require 'ramaze/snippets/string/snake_case'
require 'ramaze/snippets/string/start_with'
require 'ramaze/snippets/string/unindent'
require 'ramaze/snippets/thread/into'

Ramaze::CoreExtensions.constants.each do |const|
  ext = Ramaze::CoreExtensions.const_get(const)
  into = Module.const_get(const)

  collisions = ext.instance_methods & into.instance_methods

  if collisions.empty?
    into.__send__(:include, ext)
  else
    warn "Won't include %p with %p, %p exists" % [into, ext, collisions]
  end
end
