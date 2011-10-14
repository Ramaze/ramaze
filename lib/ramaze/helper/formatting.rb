#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper
    module Formatting
      module_function

      FORMATTING_NUMBER_COUNTER = {
        0  => 'no',
        2  => 'two',
        3  => 'three',
        4  => 'four',
        5  => 'five',
        6  => 'six',
        7  => 'seven',
        8  => 'eight',
        9  => 'nine',
        10 => 'ten'
      }

      # Answers with a representation of given +count+ with correct grammar.  If
      # no +items+ argument is given, and the +count+ argument is not 1, then we
      # first check whether the +item+ argument responds to ``#pluralize`` (for
      # example if you are using Sequel). If this doesn't work we append 's'
      # to the +item+ argument.
      #
      # @example usage
      #  number_counter(0, 'comment') # => 'no comments'
      #  number_counter(1, 'comment') # => 'one comment'
      #  number_counter(2, 'comment') # => '2 comments'
      #
      def number_counter(count, item, items = nil)
        count, item = count.to_i, item.to_s

        if count == 1
          "one #{item}"
        else
          items ||= item.respond_to?(:pluralize) ? item.pluralize : "#{item}s"
          prefix = FORMATTING_NUMBER_COUNTER[count] || count
          "#{prefix} #{items}"
        end
      end

      # Format a floating number nicely for display.
      #
      # @example
      #  number_format(123.123)           # => '123.123'
      #  number_format(123456.12345)      # => '123,456.12345'
      #  number_format(123456.12345, '.') # => '123.456,12345'
      #
      def number_format(n, delimiter = ',')
        delim_l, delim_r = delimiter == ',' ? %w[, .] : %w[. ,]
        h, r = n.to_s.split('.')
        [h.reverse.scan(/\d{1,3}/).join(delim_l).reverse, r].compact.join(delim_r)
      end

      # Answer with the ordinal version of a number.
      #
      # @example
      #  ordinal(1)   # => "1st"
      #  ordinal(2)   # => "2nd"
      #  ordinal(3)   # => "3rd"
      #  ordinal(13)  # => "13th"
      #  ordinal(33)  # => "33rd"
      #  ordinal(100) # => "100th"
      #  ordinal(133) # => "133rd"
      #
      def ordinal(number)
        number = number.to_i

        case number % 100
        when 11..13; "#{number}th"
        else
          case number % 10
          when 1; "#{number}st"
          when 2; "#{number}nd"
          when 3; "#{number}rd"
          else    "#{number}th"
          end
        end
      end

      # stolen and adapted from rails
      def time_diff(from_time, to_time = Time.now, include_seconds = false)
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round if include_seconds

        case distance_in_minutes
          when 0..1
            return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
            case distance_in_seconds
              when 0..4   then 'less than 5 seconds'
              when 5..9   then 'less than 10 seconds'
              when 10..19 then 'less than 20 seconds'
              when 20..39 then 'half a minute'
              when 40..59 then 'less than a minute'
              else             '1 minute'
            end

          when 2..44           then "#{distance_in_minutes} minutes"
          when 45..89          then 'about 1 hour'
          when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
          when 1440..2879      then '1 day'
          when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
          when 43200..86399    then 'about 1 month'
          when 86400..525959   then "#{(distance_in_minutes / 43200).round} months"
          when 525960..1051919 then 'about 1 year'
          else                      "over #{(distance_in_minutes / 525960).round} years"
        end
      end

      # Copied from actionpack, and revised by insane-dreamer to fix a bug
      # (original fails on some URLs)
      AUTO_LINK_RE = %r{
        (                          # leading text
          <\w+.*?>|                # leading HTML tag, or
          [^=!:'"/]|               # leading punctuation, or
          ^                        # beginning of line
        )
        (
          (?:https?://)|           # protocol spec, or
          (?:www\.)                # www.*
        )
        (
          [-\w]+                   # subdomain or domain
          (?:\.[-\w]+)*            # remaining subdomains or domain
          (?::\d+)?                # port
          (?:/(?:[~\w\+@%=\(\)-]|(?:[,.;:'][^\s<$]))*)* # path
          (?:\?[\w\+@%&=.;:-]+)?   # query string
          (?:\#[\w\-]*)?           # trailing anchor
        )
        ([[:punct:]]|<|$|)         # trailing text
      }x unless defined? AUTO_LINK_RE

      # Turns all urls into clickable links.  If a block is given, each url
      # is yielded and the result is used as the link text.
      def auto_link(text, opts = {})
        html_options = ' ' + opts.map{|k,v| "#{k}='#{v}'"}.join(' ') if opts.any?
        text.gsub(AUTO_LINK_RE) do
          all, a, b, c, d = $&, $1, $2, $3, $4
          if a =~ /<a\s/i # don't replace URL's that are already linked
            all
          else
            text = b + c
            text = yield(text) if block_given?
            %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}"#{html_options}>#{text}</a>#{d})
          end
        end
      end
      alias autolink auto_link

      # takes a string and optional argument for outputting compliance HTML
      # instead of XHTML.
      #
      # @example
      #  nl2br "a\nb\n\c" #=> 'a<br />b<br />c'
      #
      def nl2br(string, xhtml = true)
        br = xhtml ? '<br />' : '<br>'
        string.gsub(/\n/, br)
      end

      def obfuscate_email(email, text = nil)
        obfuscated = []
        email.to_s.each_byte{|c| obfuscated << "&#%03d" % c }
        joined = obfuscated.join

        %(<a href="mailto:#{joined}">#{text || joined}</a>)
      end

      # Returns Hash with tags as keys and their weight as value.
      #
      # Example:
      #     tags = %w[ruby ruby code ramaze]
      #     tagcloud(tags)
      #     # => {"code"=>0.75, "ramaze"=>0.75, "ruby"=>1.0}
      #
      # The weight can be influenced by adjusting the +min+ and +max+
      # parameters, please make sure that +max+ is larger than +min+ to get
      # meaningful output.
      #
      # This is not thought as immediate output to your template but rather to
      # help either implementing your own algorithm or using the result as input
      # for your tagcloud.
      #
      # @example
      #  tagcloud(tags).each do |tag, weight|
      #    style = "font-size: %0.2fem" % weight
      #    %a{:style => style, :href => Rs(tag)}= h(tag)
      #  end
      #
      def tagcloud(tags, min = 0.5, max = 1.5)
        result = {}
        total = tags.size.to_f
        diff = max - min

        tags.uniq.each do |tag|
          count = tags.respond_to?(:count) ? tags.count(tag) : tags.select{|t| t==tag }.size
          result[tag] = ((count / total) * diff) + min
        end

        result
      end
    end # Formatting
  end # Helper
end # Ramaze
