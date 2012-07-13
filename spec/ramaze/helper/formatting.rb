#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/formatting'

describe 'Helper::Formatting' do
  extend Ramaze::Helper::Formatting

  describe '#number_counter' do
    extend Ramaze::Helper::Formatting

    it 'gives a correct plural counter' do
      number_counter(0, 'comment').should == 'no comments'
      number_counter(1, 'comment').should == 'one comment'
      number_counter(2, 'comment').should == 'two comments'
      number_counter(3, 'comment').should == 'three comments'
      number_counter(4, 'comment').should == 'four comments'
      number_counter(5, 'comment').should == 'five comments'
      number_counter(6, 'comment').should == 'six comments'
      number_counter(7, 'comment').should == 'seven comments'
      number_counter(8, 'comment').should == 'eight comments'
      number_counter(9, 'comment').should == 'nine comments'
      number_counter(10, 'comment').should == 'ten comments'
      number_counter(11, 'comment').should == '11 comments'
      number_counter(12, 'comment').should == '12 comments'
    end

    it 'uses +items+ as plural version' do
      number_counter(0, 'pants', 'pants').should == 'no pants'
    end

    it 'tries using the pluralize method on +item+ if no +items+ given' do
      item = 'person'
      def item.pluralize; 'people'; end
      number_counter(0, item).should == 'no people'
    end
  end

  it 'formats numbers' do
    number_format(2_123_456).should == '2,123,456'
    number_format(1234.567).should == '1,234.567'
    number_format(123456.789, '.').should == '123.456,789'
    number_format(123456.789123, '.').should == '123.456,789123'
    number_format(132123456.789123, '.').should == '132.123.456,789123'
  end

  it 'returns difference in time as a string' do
    check = lambda{|diff, string| time_diff(Time.now - diff).should == string }

    check[1, 'less than a minute']
    check[60, '1 minute']
    check[60 * 50, 'about 1 hour']
    check[60 * 120, 'about 2 hours']
    check[60 * 60 * 24, '1 day']
    check[60 * 60 * 48, '2 days']
    check[60 * 60 * 24 * 30, 'about 1 month']
    check[60 * 60 * 24 * 60, '2 months']
    check[60 * 60 * 24 * 30 * 20, 'about 1 year']
    check[60 * 60 * 24 * 30 * 42, 'over 3 years']

    time_diff(Time.now, Time.now + 4, true).should == 'less than 5 seconds'
    time_diff(Time.now, Time.now + 6, true).should == 'less than 10 seconds'
    time_diff(Time.now, Time.now + 29, true).should == 'half a minute'
    time_diff(Time.now, Time.now + 50, true).should == 'less than a minute'
    time_diff(Time.now, Time.now + 66, true).should == '1 minute'
  end

  it 'linkifies urls' do
    auto_link("http://ramaze.net is the coolest framework, but <a href='http://merbivore.com'>merb</a> is good too").should ==
      "<a href=\"http://ramaze.net\">http://ramaze.net</a> is the coolest framework, but <a href='http://merbivore.com'>merb</a> is good too"

    auto_link("http://ramaze.net", :target => '_blank').should ==
      "<a href=\"http://ramaze.net\" target='_blank'>http://ramaze.net</a>"
  end

  it 'auto_links urls, setting the result of the given block as the link text' do
    auto_link('http://ramaze.net rocks, so does http://rubyonrails.org.') { |url| url.sub!(%r{http://}, '') }.should ==
      '<a href="http://ramaze.net">ramaze.net</a> rocks, so does <a href="http://rubyonrails.org">rubyonrails.org</a>.'
  end

  it 'ordinalizes numbers' do
    ordinal(1).should == '1st'
    ordinal(2).should == '2nd'
    ordinal(3).should == '3rd'
    ordinal(4).should == '4th'
    ordinal(10).should == '10th'
    ordinal(12).should == '12th'
    ordinal(21).should == '21st'
    ordinal(23).should == '23rd'
    ordinal(100).should == '100th'
    ordinal(133).should == '133rd'
  end

  it 'generates tagclouds' do
    tags = %w[ruby ruby code ramaze]
    tagcloud(tags).should ==
      {"code"=>0.75, "ramaze"=>0.75, "ruby"=>1.0}
    tagcloud(tags, 0.5, 2.0).should ==
      {"code"=>0.875, "ramaze"=>0.875, "ruby"=>1.25}
  end

  it 'converts newlines to br tags' do
    nl2br("foo\nbar\nfoobar").should == 'foo<br />bar<br />foobar'
    nl2br("foo\nbar\nfoobar", false).should == 'foo<br>bar<br>foobar'
  end

  it 'obfuscates email addresses' do
    obfuscate_email('foo@example.com').
      should == "<a href=\"mailto:&#102&#111&#111&#064&#101&#120&#097&#109&#112&#108&#101&#046&#099&#111&#109\">&#102&#111&#111&#064&#101&#120&#097&#109&#112&#108&#101&#046&#099&#111&#109</a>"
    obfuscate_email('foo@example.com', 'mail foo').
      should == "<a href=\"mailto:&#102&#111&#111&#064&#101&#120&#097&#109&#112&#108&#101&#046&#099&#111&#109\">mail foo</a>"
  end
end
