#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  def self.plugin(name, options = {})
    Plugin.load(name, options)
  end

  module Plugin
    PLUGIN_LIST = Set.new
    EXTS = %w[rb so bundle]
    PATH = []
    POOL = []

    module_function

    Ramaze.options.setup << self

    def setup
      PLUGIN_LIST.each do |name, const, options|
        const.setup(options) if const.respond_to?(:setup)
      end
    end

    def teardown
      PLUGIN_LIST.each do |name, const, options|
        const.teardown if const.respond_to?(:teardown)
      end
    end

    def add_pool(pool)
      POOL.unshift(pool)
      POOL.uniq!
    end

    add_pool(self)

    def add_path(path)
      PATH.unshift(File.expand_path(path))
      PATH.uniq!
    end

    add_path(__DIR__)
    add_path('')

    def load(name, options)
      name = name.to_s
      try_require(name.snake_case)
      PLUGIN_LIST << [name, const_get(name.camel_case), options]
    rescue Exception => exception
      Log.error(exception)
      raise LoadError, "Plugin #{name} not found"
    end

    def try_require(name)
      found = Dir[glob(name)].first
      require(File.expand_path(found)) if found
    rescue LoadError
    end

    def glob(name = '*')
      "{#{paths.join(',')}}/plugin/#{name}.{#{EXTS.join(',')}}"
    end

    def paths
      PATH
    end
  end
end
