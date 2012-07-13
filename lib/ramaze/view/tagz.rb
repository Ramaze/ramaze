Ramaze.setup(:verbose => false) do
  gem 'tagz'
end

module Ramaze
  module View
    module Tagz
      def self.call(action, string)
        return string, 'text/html' unless action.view

        markup = "tagz{#{string}}"
        action.instance.extend(Ramaze::View::Tagz::Methods)
        binding = action.binding

        html = eval(markup, binding, action.view)

        return html, 'text/html'
      end

      # A host of methods useful inside the context of a view including print
      # style methods that output content rather that printing to $stdout.
      module Methods
        include ::Tagz

        private

        def <<(s)
          tagz << s; self
        end

        def concat(*a)
          a.each{|s| tagz << s}; self
        end

        def puts(*a)
          a.each{|elem| tagz << "#{ elem.to_s.chomp }#{ eol }"}
        end

        def print(*a)
          a.each{|elem| tagz << elem}
        end

        def p(*a)
          a.each do |elem|
            tagz << "#{ Rack::Utils.escape_html elem.inspect }#{ eol }"
          end
        end

        def pp(*a)
          a.each do |elem|
            tagz << "#{ Rack::Utils.escape_html PP.pp(elem, '') }#{ eol }"
          end
        end

        def eol
          if response.content_type =~ %r|text/plain|io
            "\n"
          else
            "<br />"
          end
        end

        def __(*a)
          concat eol
        end
      end
    end # Tagz
  end # View
end # Ramaze
