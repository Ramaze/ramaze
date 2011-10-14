module Ramaze
  module Helper
    module RequestAccessor
      classes = [Rack::Request, Innate::Request, Ramaze::Request]
      methods = classes.map { |klass|
        klass.instance_methods(false)
      }.flatten.uniq

      methods.each do |method|
        if method =~ /=/
          eval("def %s(a) request.%s a; end" % [method, method])
        else
          eval("def %s(*a) request.%s(*a); end" % [method, method])
        end
      end
    end # RequestAccessor
  end # Helper
end # Ramaze
