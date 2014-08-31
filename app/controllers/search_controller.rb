class SearchController < ApplicationController

  def index
    mechanize = Mechanize.new
    page = mechanize.get('http://cosdna.com')

    @title = page.title
  end
end