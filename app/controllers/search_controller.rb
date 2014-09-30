class SearchController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def index
    if params["searchTerm"]
      search_string = params["searchTerm"]
      search_string = params["searchTerm"].gsub!(" ", "+") if search_string.include?(" ")
      page = Mechanize.new.get('http://cosdna.com/eng/product.php?q=' + search_string)
      page.title
      @links = page.links_with(:href => %r{^cosmetic_})
      p @links[0].href
    end
  end
end
