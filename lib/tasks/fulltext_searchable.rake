namespace :fulltext_searchable do
  task :update => :environment do
    require 'active_record'
    puts "Updating FulltextIndex..."
    FulltextIndex.all.each do |r|
      r.update_attribute(:text, r.item.fulltext_keywords)
    end
    puts "Done."
  end
  task :rebuild => :environment do
    puts "Rebuilding FulltextIndex..."

    # read all models
    require 'active_record'
    Dir["#{Rails.root}/app/models/*"].each do |file|
      require file
    end

    FulltextIndex.rebuild_all
    puts "Done."
  end
end

