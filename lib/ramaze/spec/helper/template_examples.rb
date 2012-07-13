#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

shared :template_spec do
  behaves_like :rack_test

  def spec_template(spec_engine)
    it 'works on /' do
      get('/').body.strip.
        should =~ %r{<a href\s*=\s*"/">Home</a>\s+\|\s+<a href\s*=\s*"/internal">internal</a>\s+\|\s+<a href\s*=\s*"/external">external</a>}
    end

    %w[/internal /external].each do |url|
      it "works on #{url}" do
        html = get(url).body
        html.should.not == nil
        html.should =~ %r{<title>Template::#{spec_engine} (internal|external)</title>}
        html.should =~ %r{<h1>The (internal|external) Template for #{spec_engine}</h1>}
      end
    end
  end
end
