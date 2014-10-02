class SearchController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def index
    if params["searchTerm"]
      search_string = params["searchTerm"]
      search_string = params["searchTerm"].gsub!(" ", "+") if search_string.include?(" ")
    end
  end
end
