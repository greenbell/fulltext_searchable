namespace :fulltext_searchable do
  task :update => :environment do
    require 'active_record'
    puts "Updating FulltextIndex..."
    FulltextIndex.all.each do |r|
      if r.item.nil?
        puts "Model:#{r.item.class.name} id:#{r.item_id} not found. May deleted."
      else
        r.update_attribute(:text, r.item.fulltext_keywords)
      end
    end
    puts "Done."
  end
  task :rebuild => :environment do
    puts "Rebuilding FulltextIndex..."

    # read all models
    require 'active_record'
    Dir["#{Rails.root}/app/models/*"].each do |file|
      require file if File::ftype(file) == "file"
    end

    FulltextIndex.rebuild_all
    puts "Done."
  end
end

