require 'rubygems'
require 'ramaze'

require __DIR__ 'model/history'
require __DIR__ 'model/message'

class ChatRoom < Ramaze::Controller
  map '/'
  HISTORY = History.new

  [ "Hello, World!",
    "My name is manveru",
    "I welcome you to my realm",
    "The unique and most awesome examples/chat.rb!",
  ].each{|text| HISTORY.write('manveru', text) }

  layout :default

  def index
    return unless request.post?
    session[:nick] = h(request[:nick])
    redirect r(:chat)
  end

  def chat
    redirect r(:/) unless session[:nick]
  end

  def say
    nick, text = session[:nick], request[:text]
    HISTORY.write(nick, h(text)) if nick and text
  end

  def listen
    respond HISTORY.to_html
  end
end

Ramaze.start :mode => :live
