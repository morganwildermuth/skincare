class SearchController < ApplicationController

  def index
    mechanize = Mechanize.new
    searchString = params["searchTerm"].gsub!(" ", "+")
    page = mechanize.get('http://cosdna.com/eng/product.php?q=' + searchString)
    @title = page.title
  end
end