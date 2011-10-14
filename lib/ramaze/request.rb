#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Ramaze
  ##
  # The purpose of this class is to act as a simple wrapper for Rack::Request
  # and provide some convinient methods for our own use.
  class Request < Innate::Request
    ##
    # you can access the original @request via this method_missing,
    # first it tries to match your method with any of the HTTP parameters
    # then, in case that fails, it will relay to @request
    def method_missing meth, *args
      key = meth.to_s.upcase
      return env[key] if env.has_key?(key)
      super
    end

    ##
    # Sets any arguments passed as @instance_variables for the current action.
    #
    # Usage:
    #
    #     request.params # => {'name' => 'manveru', 'q' => 'google', 'lang' => 'de'}
    #     request.to_ivs(:name, :q)
    #
    #     @q    # => 'google'
    #     @name # => 'manveru'
    #     @lang # => nil
    #
    def to_instance_variables(*args)
      instance = Current.action.instance
      args.each do |arg|
        next unless value = self[arg]
        instance.instance_variable_set("@#{arg}", value)
      end
    end
    alias to_ivs to_instance_variables

    def accept_charset(default = 'UTF-8')
      return default unless charsets = env['HTTP_ACCEPT_CHARSET']
      charset = charsets.split(',', 2).first
      charset == '*' ? default : charset
    end

    ##
    # Try to find out which languages the client would like to have and sort
    # them by weight, (most wanted first).
    #
    # Returns and array of locales from env['HTTP_ACCEPT_LANGUAGE].
    # e.g. ["fi", "en", "ja", "fr", "de", "es", "it", "nl", "sv"]
    #
    # Usage:
    #
    #     request.accept_language # => ['en-us', 'en', 'de-at', 'de']
    #
    # @param [String #to_s] string the value of HTTP_ACCEPT_LANGUAGE
    # @return [Array] list of locales
    # @see Request#accept_language_with_weight
    # @author manveru
    #
    def accept_language(string = env['HTTP_ACCEPT_LANGUAGE'])
      return [] unless string

      accept_language_with_weight(string).map{|lang, weight| lang }
    end
    alias locales accept_language

    ##
    # Transform the HTTP_ACCEPT_LANGUAGE header into an Array with:
    #
    #     [[lang, weight], [lang, weight], ...]
    #
    # This algorithm was taken and improved from the locales library.
    #
    # Usage:
    #
    #     request.accept_language_with_weight
    #     # => [["en-us", 1.0], ["en", 0.8], ["de-at", 0.5], ["de", 0.3]]
    #
    # @param [String #to_s] string the value of HTTP_ACCEPT_LANGUAGE
    # @return [Array] array of [lang, weight] arrays
    # @see Request#accept_language
    # @author manveru
    #
    def accept_language_with_weight(string = env['HTTP_ACCEPT_LANGUAGE'])
      string.to_s.gsub(/\s+/, '').split(',').
            map{|chunk|        chunk.split(';q=', 2) }.
            map{|lang, weight| [lang, weight ? weight.to_f : 1.0] }.
        sort_by{|lang, weight| -weight }
    end

    INTERESTING_HTTP_VARIABLES =
      (/USER|HOST|REQUEST|REMOTE|FORWARD|REFER|PATH|QUERY|VERSION|KEEP|CACHE/)

    # Interesting HTTP variables from env
    def http_variables
      env.reject{|key, value| key.to_s !~ INTERESTING_HTTP_VARIABLES }
    end
    alias http_vars http_variables

    REQUEST_STRING_FORMAT = "#<%s params=%p cookies=%p env=%p>"

    def to_s
      REQUEST_STRING_FORMAT % [self.class, params, cookies, http_variables]
    end
    alias inspect to_s

    # Pretty prints current action with parameters, cookies and enviroment
    # variables.
    def pretty_print(pp)
      pp.object_group(self) do
        group = {
          'params'  => params,
          'cookies' => cookies,
          'env'     => http_variables
        }

        group.each do |name, hash|
          pp.breakable
          pp.text " @#{name}="
          pp.nest(name.size + 3){ pp.pp_hash(hash) }
        end
      end
    end
  end # Request
end # Ramaze
