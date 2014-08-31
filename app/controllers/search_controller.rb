class SearchController < ApplicationController

  def index
    require 'rubygems'
    require 'mechanize'
    mechanize = Mechanize.new
    page = mechanize.get('http://stackoverflow.com/')

    @title = page.title
  end
end