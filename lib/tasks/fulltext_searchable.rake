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

    FulltextIndex.connection.execute("TRUNCATE `#{FulltextIndex.table_name}`")
    puts "FulltextIndex flushed."
    
    ActiveRecord::Base.descendants.each do |model|
      next unless model.ancestors.include?(::FulltextSearchable::ActiveRecord::InstanceMethods)
      puts "Indexing model #{model.name}."
      model.all.each do |r|
        FulltextIndex.create :text => r.fulltext_keywords
      end
    end
    puts "Done."
  end
end

