#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'hpricot'

class SpecHelperPaginateArray < Ramaze::Controller
  map '/array'
  helper :paginate

  ALPHA = %w[ alpha beta gamma delta epsilon zeta eta theta iota kappa lambda
              mu nu xi omicron pi rho sigma tau ypsilon phi chi psi omega ]

  def navigation
    pager = paginate(ALPHA)
    pager.navigation
  end

  def custom_navigation
    css = {:first => "TheFirst", :prev => "ThePrevious", :next => "TheNext",
           :last => "TheLast", :number => "TheNumber",
           :disabled =>"Severely Disabled", :current => "TheCurrent" }

    pager = paginate(ALPHA, :css => css)
    pager.navigation
  end

  def iteration
    pager = paginate(ALPHA)
    out = []
    pager.each{|item| out << item }
    out.inspect
  end
end

describe Ramaze::Helper::Paginate do
  describe 'Array' do
    behaves_like :rack_test

    it 'shows navigation for page 1' do
      doc = Hpricot(get("/array/navigation").body)
      (doc/:a).map{|a| [a.inner_text, a[:href]] }.
        should == [
          ['1', '/array/navigation?pager=1'],
          ['2', '/array/navigation?pager=2'],
          ['3', '/array/navigation?pager=3'],
          ['>', '/array/navigation?pager=2'],
          ['>>', '/array/navigation?pager=3']]
    end

    it 'shows navigation for page 2' do
      doc = Hpricot(get("/array/navigation?pager=2").body)
      (doc/:a).map{|a| [a.inner_text, a[:href]] }.
        should == [
          ['<<', '/array/navigation?pager=1'],
          ['<', '/array/navigation?pager=1'],
          ['1', '/array/navigation?pager=1'],
          ['2', '/array/navigation?pager=2'],
          ['3', '/array/navigation?pager=3'],
          ['>', '/array/navigation?pager=3'],
          ['>>', '/array/navigation?pager=3']]
    end

    it 'shows navigation for page 3' do
      doc = Hpricot(get("/array/navigation?pager=3").body)
      (doc/:a).map{|a| [a.inner_text, a[:href]] }.
        should == [
          ['<<', '/array/navigation?pager=1'],
          ['<', '/array/navigation?pager=2'],
          ['1', '/array/navigation?pager=1'],
          ['2', '/array/navigation?pager=2'],
          ['3', '/array/navigation?pager=3']]
    end

    it 'iterates over the items in the pager' do
      got = get('/array/iteration')
      got.body.scan(/\w+/).should == SpecHelperPaginateArray::ALPHA.first(10)
    end

    it 'sets default css elements on page 1' do
      doc = Hpricot(get('/array/navigation').body)
      # Paginator outputs spans for disabled elements
      # Since we're on the first page, the first two
      # elements are spans, then a's
      # Note that this is only valid for the first page since
      # it doens't need lonks to first and prev
      #
      # Looking for spans first
      spans = doc.search("//span")
      first = spans.first[:class]
      first.should == "first grey"

      prev = spans[1][:class]
      prev.should == "prev grey"

      # Looking for a elements
      as =  doc.search("//a")
      current = as.first[:class]
      current.should == "current "

      randomnumber = as[1][:class]
      randomnumber.should == ""

      nxt = as[3][:class]
      nxt.should == "next"

      last = as[4][:class]
      last.should == "last"
    end

    it 'sets default css elements on page 2' do
      doc = Hpricot(get('/array/navigation?pager=2').body)
      # Paginator outputs spans for disabled elements
      # Since we're on the second page, none are disabled
      # Note that this is only valid for the second page since
      # it will have all the links, while 1 and 3 have some disabled
      #
      # Looking for a elements
      as =  doc.search("//a")
      first = as.first[:class]
      first.should == "first"

      prev = as[1][:class]
      prev.should == "prev"

      pg1 = as[2][:class]
      pg1.should == ""

      current = as[3][:class]
      current.should == "current "

      pg3 = as[4][:class]
      pg3.should == ""

      nxt = as[5][:class]
      nxt.should == "next"

      last = as[6][:class]
      last.should == "last"
    end

    it 'sets default css elements on page 3' do
      doc = Hpricot(get('/array/navigation?pager=3').body)
      # Paginator outputs spans for disabled elements
      # Since we're on the last page, last and next will be disabled
      # Note that this is only valid for the third page
      #
      # Looking for a elements
      as =  doc.search("//a")
      first = as.first[:class]
      first.should == "first"

      prev = as[1][:class]
      prev.should == "prev"

      pg1 = as[2][:class]
      pg1.should == ""

      pg2 = as[3][:class]
      pg2.should == ""

      current = as[4][:class]
      current.should == "current "

      # Looking for span elements
      spans =  doc.search("//span")
      first = spans.first[:class]
      first.should == "next grey"

      last = spans[1][:class]
      last.should == "last grey"

    end

    it 'sets our custom css elements for page 1' do
      doc = Hpricot(get('/array/custom_navigation').body)
      # Paginator outputs spans for disabled elements
      # Since we're on the first page, the first two
      # elements are spans, then a's
      # Note that this is only valid for the first page since
      # it doens't need lonks to first and prev
      #
      # Looking for spans first
      spans = doc.search("//span")
      first = spans.first[:class]
      first.should.include? "TheFirst"
      first.should.include? "Disabled"
      first.should.include? "Severely"

      prev = spans[1][:class]
      prev.should.include? "Severely"
      prev.should.include? "Disabled"
      prev.should.include? "ThePrevious"

      # Looking for a elements
      as =  doc.search("//a")
      current = as.first[:class]
      current.should.include? "TheCurrent"
      current.should.include? "TheNumber"

      randomnumber = as[1][:class]
      randomnumber.should.include? "TheNumber"

      nxt = as[3][:class]
      nxt.should.include? "TheNext"

      last = as[4][:class]
      last.should.include? "TheLast"
    end

    it 'sets our custom css elements on page 2' do
      doc = Hpricot(get('/array/custom_navigation?pager=2').body)
      # Paginator outputs spans for disabled elements
      # Since we're on the second page, none are disabled
      # Note that this is only valid for the second page since
      # it will have all the links, while 1 and 3 have some disabled
      #
      # Looking for a elements
      as =  doc.search("//a")
      first = as.first[:class]
      first.should == "TheFirst"

      prev = as[1][:class]
      prev.should == "ThePrevious"

      pg1 = as[2][:class]
      pg1.should == "TheNumber"

      current = as[3][:class]
      current.should == "TheCurrent TheNumber"

      pg3 = as[4][:class]
      pg3.should == "TheNumber"

      nxt = as[5][:class]
      nxt.should == "TheNext"

      last = as[6][:class]
      last.should == "TheLast"
    end

    it 'sets our custom css elements on page 3' do
      doc = Hpricot(get('/array/custom_navigation?pager=3').body)
      # Paginator outputs spans for disabled elements
      # Since we're on the last page, last and next will be disabled
      # Note that this is only valid for the third page
      #
      # Looking for a elements
      as =  doc.search("//a")
      first = as.first[:class]
      first.should == "TheFirst"

      prev = as[1][:class]
      prev.should == "ThePrevious"

      pg1 = as[2][:class]
      pg1.should == "TheNumber"

      pg2 = as[3][:class]
      pg2.should == "TheNumber"

      current = as[4][:class]
      current.should == "TheCurrent TheNumber"

      # Looking for span elements
      spans =  doc.search("//span")
      first = spans.first[:class]
      first.should == "TheNext Severely Disabled"

      last = spans[1][:class]
      last.should == "TheLast Severely Disabled"

    end

  end
end
