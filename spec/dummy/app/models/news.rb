class News < ActiveRecord::Base
  fulltext_searchable [:title, :body]
end
