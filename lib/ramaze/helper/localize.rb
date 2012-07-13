require 'locale/tag'
require 'locale'

module Ramaze
  module Helper
    ##
    # The localization helper can be used to output translated strings.  This
    # enables your application to use multiple language files for English, Dutch
    # and so on.
    #
    module Localize
      include Traited

      trait :localize_locale => ::Locale::Tag::Simple.new('en')
      trait :localize_charset => 'UTF-8'

      def localize(string, substitute = nil)
        localize_dictionary.translate(string, locales, substitute)
      end
      alias l localize

      def locale
        locales.first
      end

      def locales
        locales = request.env['localize.locales']
        return locales if locales

        fallback = ancestral_trait[:localize_locale]
        locales = Parser.new(request).locales(fallback)
        request.env['localize.locales'] = locales
      end

      class Dictionary
        attr_reader :dict

        def initialize
          @dict = {}
        end

        def translate(string, locales, substitute)
          target = string.to_s.dup
          locales = locales.flatten.uniq

          if substitute
            substitute.each do |key, value|
              target.gsub!(/\{#{Regexp.escape(key)}\}/, lookup(value, locales))
            end
            return target
          elsif target =~ /\{/
            target.gsub!(/\{([^\}]+)\}/){ lookup($1, locales) }
            return target
          else
            lookup(target, locales)
          end
        end

        def lookup(string, locales)
          locales.each do |locale|
            next unless dict = self[locale]
            next unless translated = dict[string]
            return translated
          end

          string
        end

        def locales
          @dict.keys
        end

        def [](locale)
          @dict[arg_to_locale(locale)]
        end

        def []=(locale, dict)
          @dict[arg_to_locale(locale)] = dict
        end

        def load(locale, options = {})
          if file = options.delete(:yaml)
            dict = ::YAML.load_file(file)
          elsif hash = options.delete(:hash)
            dict = hash
          elsif marshal = options.delete(:marshal)
            dict = Marshal.load(File.read(marshal))
          else
            raise ArgumentError, "either :yaml, :marshal, or :hash"
          end

          @dict[arg_to_locale(locale)] = dict
        end

        private

        def arg_to_locale(arg, raises = true)
          if raises and not arg
            raise(ArgumentError, "%p cannot be converted to a Locale" % arg)
          end
          arg.respond_to?(:language) ? arg : ::Locale::Tag.parse(arg.to_s)
        end
      end

      class Parser
        attr_accessor :request

        def initialize(request)
          @request = request
        end

        def locales(fallback = nil)
          locales = [parse, fallback].flatten.uniq
          ::Locale::TagList.new(locales)
        end

        def parse
          parse_params || parse_session || parse_cookie || parse_header
        end

        def parse_params(key = 'lang')
          return unless lang = request.params[key]
          ::Locale::Tag.parse(lang)
        end

        def parse_session(key = :lang)
          return unless lang = Current.session[key]
          ::Locale::Tag.parse(lang)
        end

        def parse_cookie(key = 'lang')
          return unless lang = request.cookies[key]
          ::Locale::Tag.parse(lang)
        end

        def parse_header
          request.accept_language.map{|lang|
            ::Locale::Tag.parse(lang) }
        end
      end
    end # Localize
  end # Helper
end # Ramaze
