#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)

module SpecBlog
  class Controller < Ramaze::Controller
    map nil, :blog
    app.location = '/'
  end

  class Posts < Controller
    map '/posts'

    def index
      'The Blog Posts'
    end
  end
end

module SpecWiki
  class Controller < Ramaze::Controller
    map nil, :wiki
    app.location = '/wiki'
  end

  class Pages < Controller
    map '/pages'

    def index
      'The Wiki Page'
    end
  end
end

describe Ramaze::App do
  behaves_like :rack_test

  it "Doesn't set location for app automatically" do
    get('/wiki/pages').body.should == 'The Wiki Page'
    get('/posts').body.should == 'The Blog Posts'
  end
end
