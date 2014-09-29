class SearchController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def index
    # cosDNA_files_to_sync = Dir.entries("/Users/WEF6/desktop/cosdna (1).tar/eng/").select{|file| file[/^cosmetic/]}
    # syncObject = Sync::Cosdna::Database.new("/Users/WEF6/desktop/cosdna (1).tar/eng/", cosDNA_files_to_sync).syncFiles
    if params["searchTerm"]
      search_string = params["searchTerm"].gsub!(" ", "+")
      page = Mechanize.new.get('http://cosdna.com/eng/product.php?q=' + search_string)
      page.title
      @links = page.links_with(:href => %r{^cosmetic_})
    end
  end
end
