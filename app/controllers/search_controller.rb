class SearchController < ApplicationController
  require './lib/syncDatabase.rb'
  require 'open-uri'
  require 'nokogiri'

  def index
    syncObject = Sync::Database.new("/Users/WEF6/desktop/cosdna (1).tar/eng/cosmetic_8898132233.html")
    syncObject.parseCosDNAProduct
    if params["searchTerm"]
      searchString = params["searchTerm"].gsub!(" ", "+")
      page = Mechanize.new.get('http://cosdna.com/eng/product.php?q=' + searchString)
      page.title
      @links = page.links_with(:href => %r{^cosmetic_})
    end
  end
end
