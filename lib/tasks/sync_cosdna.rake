 require_relative '../../app/modules/sync.rb'
 namespace :sync do

    # example: rake sync:cosdna["/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna/"]
    desc "sync with cosdna data"
    task :cosdna, [:folder_path] => :environment do |task, arguments|
      folder_path = arguments[:folder_path]
      files_to_sync = Dir.entries(folder_path).select{|file| file[/^cosmetic/]}
      p "Sync with Cosdna Files from #{folder_path} starting..."
      Sync::Cosdna::Database.new(folder_path, files_to_sync).syncFiles
    end
  end