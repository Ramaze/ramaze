#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
#           Copyright (c) 2007  Stephan Maka  stephan@spaceboyz.net
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'
require 'ramaze/gestalt'

include Ramaze

class MainController < Controller
  template_root __DIR__/:template
  trait :engine => Template::XSLT

  def index
    redirect R(:external)
  end

  def external *args
    r = lambda { |*a| R(*a) }
    response['Content-Type'] = 'application/xhtml+xml'

    #options = {:place => :internal, :action => 'internal',
    #  :args => args, :request => request, :this => self}
    Ramaze::Gestalt.build do
      page(:title=>"Template::XSLT") do
        heading "The external Template for XSLT"
        text "Here you can pass some stuff if you like, parameters are just passed like this:"
        list do
          item {
            link(:href => r.call(@this, :external, :one)) { "external/one" }
          }
          item {
            link(:href => r.call(@this, :external, :one, :two, :three)) { "external/one/two/three" }
          }
          item {
            link(:href => r.call(@this, :external, :one, :foo => :bar)) { "external/one?foo=bar" }
          }
        end
        text "The arguments you have passed to this action are:"
        if args.empty?
          text "none"
        else
          list {
            args.each do |arg|
              item arg
            end
          }
        end
      end
    end
  end
end

Ramaze.start
