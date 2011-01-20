class Blog < ActiveRecord::Base
  fulltext_searchable [:title, :body]
end
