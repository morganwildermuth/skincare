class SearchController < ApplicationController

  def index
    mechanize = Mechanize.new
    searchString = params["searchTerm"].gsub!(" ", "+")
    page = mechanize.get('http://cosdna.com/eng/product.php?q=' + searchString)
    @links = page.links_with(:href => %r{^cosmetic_})
  end
end