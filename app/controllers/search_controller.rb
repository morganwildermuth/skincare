class SearchController < ApplicationController

  def index
    mechanize = Mechanize.new
    page = mechanize.get('http://stackoverflow.com/')

    @title = page.title
  end
end