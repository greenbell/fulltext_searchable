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

    # load all models
    require 'active_record'
    base_path = "#{Rails.root}/app/models/"
    Dir["#{base_path}**/*.rb"].map do |filename|
      filename.gsub(base_path, '').chomp('.rb').camelize
    end.flatten.reject { |m| m.starts_with?('Concerns::') }.each do |m|
      begin
        m.constantize
      rescue LoadError
        puts "Failed to load '#{m}'. Assuming non-existent.."
      end
    end

    FulltextIndex.rebuild_all
    puts "Done."
  end
end

