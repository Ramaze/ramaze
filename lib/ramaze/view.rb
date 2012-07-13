#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  View = Innate::View

  # This is a container module for wrappers of templating engines and handles
  # lazy requiring of needed engines.
  module View
    # Combine Kernel#autoload and Innate::View::register
    def self.auto_register(name, *exts)
      autoload(name, "ramaze/view/#{name}".downcase)
      register("Innate::View::#{name}", *exts)
    end

    # Engines provided by Innate are:
    # ERB, Etanni, None
    auto_register :Erector,    :erector
    auto_register :Erubis,     :erubis,  :rhtml
    auto_register :Ezamar,     :zmr
    auto_register :Gestalt,    :ges
    auto_register :Haml,       :haml
    auto_register :Less,       :lss, :less
    auto_register :Liquid,     :liquid
    auto_register :Lokar,      :lok
    auto_register :Nagoro,     :nag
    auto_register :Remarkably, :rem
    auto_register :Sass,       :sass
    auto_register :Slim,       :slim
    auto_register :Tagz,       :tagz
    auto_register :Tenjin,     :rbhtml, :tenjin
    auto_register :Slippers,   :st
    auto_register :Mustache,   :mustache, :mt
  end # View
end # Ramaze
