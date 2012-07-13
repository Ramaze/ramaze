#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

# Namespace for Ramaze
#
# THINK:
#   * for now, we don't extend this with Innate to keep things clean. But we
#     should eventually do it for a simple API, or people always have to find
#     out whether something is in Innate or Ramaze.
#     No matter which way we go, we should keep references point to the
#     original location to avoid too much confusion for core developers.
module Ramaze
  ROOT = File.expand_path(File.dirname(__FILE__)) unless defined?(Ramaze::ROOT)

  # 3rd party
  require 'innate'

  @options = Innate.options
  class << self; attr_accessor :options; end

  unless $LOAD_PATH.any?{|lp| File.expand_path(lp) == ROOT }
    $LOAD_PATH.unshift(ROOT)
  end

  # vendored, will go into rack-contrib
  require 'vendor/route_exceptions'

  # Ramaze itself
  require 'ramaze/version'
  require 'ramaze/log'
  require 'ramaze/snippets'
  require 'ramaze/helper'
  require 'ramaze/view'
  require 'ramaze/controller'
  require 'ramaze/cache'
  require 'ramaze/reloader'
  require 'ramaze/setup'
  require 'ramaze/app'
  require 'ramaze/files'
  require 'ramaze/middleware_compiler'
  require 'ramaze/plugin'
  require 'ramaze/request'
  require 'ramaze/current'

  # Usually it's just mental overhead to remember which module has which
  # constant, so we just assign them here as well.
  # This will not affect any of the module functions on Innate, you still have
  # to reference the correct module for them.
  # We do not set constants already set from the requires above.
  Innate.constants.each do |const|
    begin
      Ramaze.const_get(const)
    rescue NameError
      Ramaze.const_set(const, Innate.const_get(const))
    end
  end

  extend Innate::SingletonMethods

  options[:middleware_compiler] = Ramaze::MiddlewareCompiler

  middleware! :dev do |m|
    m.use Rack::Lint
    m.use Rack::CommonLogger, Ramaze::Log
    m.use Rack::ShowExceptions
    m.use Rack::ShowStatus
    m.use Rack::RouteExceptions
    m.use Rack::ConditionalGet

    # FIXME: This works around differences between Rack 1.2.1 and the git HEAD
    if Rack::ETag.instance_method(:initialize).arity == 1
      m.use Rack::ETag
    else
      m.use Rack::ETag, 'public'
    end

    m.use Rack::Head
    m.use Ramaze::Reloader
    m.run Ramaze::AppMap
  end

  middleware! :live do |m|
    m.use Rack::CommonLogger, Ramaze::Log
    m.use Rack::RouteExceptions
    m.use Rack::ShowStatus
    m.use Rack::ConditionalGet

    # FIXME: This works around differences between Rack 1.2.1 and the git HEAD
    if Rack::ETag.instance_method(:initialize).arity == 1
      m.use Rack::ETag
    else
      m.use Rack::ETag, 'public'
    end

    m.use Rack::Head
    m.run Ramaze::AppMap
  end
end
