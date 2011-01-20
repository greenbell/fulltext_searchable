namespace :fulltext_searchable do
  task :update => :environment do
    require 'active_record'
    puts "Updating FulltextIndex..."
    FulltextIndex.all.each do |r|
      r.update_attribute(:text, r.item.fulltext_keywords)
    end
    puts "Done."
  end
end

