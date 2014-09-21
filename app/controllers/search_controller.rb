class SearchController < ApplicationController
  require './lib/syncDatabase.rb'

  def index
    syncObject = Sync::Database.new
    p syncObject
    mechanize = Mechanize.new
    if params["searchTerm"]
      searchString = params["searchTerm"].gsub!(" ", "+")
      page = mechanize.get('http://cosdna.com/eng/product.php?q=' + searchString)
      @links = page.links_with(:href => %r{^cosmetic_})
    end
  end
end